# Set system time using Google's server timestamp
date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"

# Add ARM hardware float architecture support
dpkg --add-architecture armhf
apt update
# Install required dependencies including ARM libraries, build tools, and graphics libraries
apt install -y libc6:armhf cmake gcc-arm-linux-gnueabihf xorg libncurses6 cabextract libncurses6:armhf libpng-dev:armhf libvulkan1 vulkan-tools vulkan-validationlayers libgl1-mesa-dri libgl1-mesa-glx libvulkan1:armhf mesa-vulkan-drivers:armhf  libgl1:armhf libglvnd0:armhf libglx-mesa0:armhf libglx0:armhf libx11-xcb1:armhf libxcb-dri2-0:armhf libxcb-glx0:armhf libxcb-present0:armhf libxcb-randr0:armhf libxcb-sync1:armhf libxcb-xfixes0:armhf libxshmfence1:armhf libxxf86vm1:armhf libgl1-mesa-dri:armhf libgl1:armhf qjoypad libxrandr2:armhf libxcomposite1:armhf

# Download and extract Wine i386 packages
wget https://dl.winehq.org/wine-builds/debian/dists/bookworm/main/binary-i386/wine-stable-i386_8.0.2~bookworm-1_i386.deb
dpkg-deb -xv wine-stable-i386_8.0.2~bookworm-1_i386.deb /root/wine-installer
rm wine-stable-i386_8.0.2~bookworm-1_i386.deb

wget https://dl.winehq.org/wine-builds/debian/dists/bookworm/main/binary-i386/wine-stable_8.0.2~bookworm-1_i386.deb
dpkg-deb -xv wine-stable_8.0.2~bookworm-1_i386.deb /root/wine-installer
rm wine-stable_8.0.2~bookworm-1_i386.deb

# Move Wine files to final location and cleanup
mv /root/wine-installer/opt/wine-stable /root/wine
rm -rf /root/wine-installer

# Create Wine wrapper scripts that use box86
echo '#!/bin/bash' > /usr/local/bin/wine
echo 'box86 /root/wine/bin/wine "$@"' >> /usr/local/bin/wine
chmod +x /usr/local/bin/wine

echo '#!/bin/bash' > /usr/local/bin/wineboot
echo 'box86 /root/wine/bin/wineboot "$@"' >> /usr/local/bin/wineboot
chmod +x /usr/local/bin/wineboot

echo '#!/bin/bash' > /usr/local/bin/winecfg
echo 'box86 /root/wine/bin/winecfg "$@"' >> /usr/local/bin/winecfg
chmod +x /usr/local/bin/winecfg

echo '#!/bin/bash' > /usr/local/bin/wineserver
echo 'box86 /root/wine/bin/wineserver "$@"' >> /usr/local/bin/wineserver
chmod +x /usr/local/bin/wineserver

# Download and install Winetricks
wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks && mv winetricks /usr/local/bin/

#
# Build and install box86 (x86 emulator for ARM)
git clone https://github.com/ptitSeb/box86
cd box86
mkdir build; cd build; cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
#this breaks diablo?
#mkdir build; cd build; cmake .. -DA64=1 -DARM_DYNAREC=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -j2
make install
sudo systemctl restart systemd-binfmt
cd ../..
rm -rf box86

# Build and install FreeType font engine
wget https://download.savannah.gnu.org/releases/freetype/freetype-2.10.1.tar.gz
tar xf freetype-2.10.1.tar.gz
cd freetype-2.10.1
./configure --host=arm-linux-gnueabihf --prefix=/usr
make -j4
make install
cd ..
rm -rf freetype*

# Set display for X server
export DISPLAY=:0

# Initialize new Wine prefix
rm -rf /root/.wine
WINEPREFIX="$HOME/.wine"
export WINEPREFIX="$HOME/.wine"
export WINEDEBUG=-all
export WINE_MONO_SILENT_INSTALL=1
export WINE_GECKO_SILENT_INSTALL=1
export BOX86_LD_LIBRARY_PATH=/usr/lib/arm-linux-gnueabihf/
export BOX86_GL=1
export BOX86_VULKAN=1

# Initialize Wine environment
wine wineboot --init

# Configure Wine settings
# Set Windows version to XP
wine reg add "HKEY_CURRENT_USER\Software\Wine\Version" /v Windows /t REG_SZ /d "winxp" /f
# Map D: drive to SD card
wine reg add "HKEY_LOCAL_MACHINE\System\MountPoints2\D:" /v "Path" /t REG_SZ /d "/mnt/sdcard" /f
# Set default resolution
wine reg ADD "HKCU\\Software\Wine\Explorer\Desktops" /v Default /d 640x480
wine reg ADD "HKCU\\Software\Wine\Explorer" /v Desktop /d Default

# Update drives configuration
cat > "$WINEPREFIX/system.reg" << EOF
WINE REGISTRY Version 2
;; All keys relative to \\\\REGISTRY\\\\MACHINE\\\\Software\\\\Wine\\\\
win
[System\\\\MountPoints2\\\\D:]
"Path"="/mnt/sdcard"
EOF

ln -sf /mnt/sdcard "$WINEPREFIX/dosdevices/d:"

# Force Wine configuration update
wine wineboot -u

# Kill any remaining Wine processes
wineserver -k

winetricks d3dx9

# Create directory if it doesn't exist
mkdir -p /root/.qjoypad3

# Create the layout file
cat > /root/.qjoypad3/default.lyt << 'EOL'
# QJoyPad 4.3 Layout File

Joystick 1 {
	Axis 4: gradient, maxSpeed 2, mouse+h
	Axis 5: gradient, maxSpeed 2, mouse+v
	Button 1: key 38
	Button 2: key 56
	Button 3: key 29
	Button 4: key 53
	Button 5: mouse 1
	Button 6: mouse 3
	Button 7: key 22
	Button 8: key 36
	Button 9: key 9
	Button 10: mouse 4
	Button 11: mouse 5
}
EOL

cp -r /root/.qjoypad3 /.qjoypad3

XZ_OPT=-9 tar -Jcvf /root/wine.recovery.tar.xz /root/.wine

# Create the launch file
cat > /mnt/mmc/Roms/APPS/wine.sh << 'EOL'
cd /root

echo "[$(date)] Starting wine startup script" >> /tmp/wine_startup.log

echo "[$(date)] Killing any existing X server processes" >> /tmp/wine_startup.log
pkill Xorg >> /tmp/wine_startup.log 2>&1
pkill startx >> /tmp/wine_startup.log 2>&1

echo "[$(date)] Setting WINEPREFIX to /root/.wine" >> /tmp/wine_startup.log
export WINEPREFIX=/root/.wine

echo "[$(date)] Starting X server" >> /tmp/wine_startup.log
startx >> /tmp/wine_startup.log 2>&1 &

echo "[$(date)] Waiting 30 seconds for X server to initialize" >> /tmp/wine_startup.log
sleep 5

echo "[$(date)] Setting DISPLAY variable" >> /tmp/wine_startup.log
export DISPLAY=:0

echo "[$(date)] Starting QJoyPad" >> /tmp/wine_startup.log

# Function to check if qjoypad is running
is_qjoypad_running() {
    pgrep -x qjoypad >/dev/null
}

# Start the monitor process
(
    while true; do
        if ! is_qjoypad_running; then
            echo "[$(date)] QJoyPad not running, restarting..." >> /tmp/wine_startup.log
            qjoypad default >> /tmp/wine_startup.log 2>&1 &
        fi
        sleep 5
    done
) &

# Store the monitor process ID
MONITOR_PID=$!

echo "[$(date)] Starting Wine Explorer" >> /tmp/wine_startup.log
wine explorer >> /tmp/wine_startup.log 2>&1

echo "[$(date)] Wine Explorer exited, cleaning up processes" >> /tmp/wine_startup.log
killall startx >> /tmp/wine_startup.log 2>&1
killall qjoypad >> /tmp/wine_startup.log 2>&1
# Make sure to clean up the monitor process when the script exits
trap "kill $MONITOR_PID 2>/dev/null" EXIT

echo "[$(date)] Script completed" >> /tmp/wine_startup.log
EOL
