SCRIPT_DIR=$(dirname "$0")
LOG_FILE="$SCRIPT_DIR/wine_install.log"

echo "[$(date)] Starting Wine installation script" >> "$LOG_FILE"

echo "[$(date)] Setting system time using Google's server" >> "$LOG_FILE"
date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z" >> "$LOG_FILE" 2>&1

echo "[$(date)] Adding ARM hardware float architecture support" >> "$LOG_FILE"
dpkg --add-architecture armhf >> "$LOG_FILE" 2>&1

echo "[$(date)] Updating package lists" >> "$LOG_FILE"
apt update >> "$LOG_FILE" 2>&1

echo "[$(date)] Installing required dependencies" >> "$LOG_FILE"
apt install -y libc6:armhf cmake gcc-arm-linux-gnueabihf xorg libncurses6 cabextract libncurses6:armhf libpng-dev:armhf libvulkan1 vulkan-tools vulkan-validationlayers libgl1-mesa-dri libgl1-mesa-glx libvulkan1:armhf mesa-vulkan-drivers:armhf  libgl1:armhf libglvnd0:armhf libglx-mesa0:armhf libglx0:armhf libx11-xcb1:armhf libxcb-dri2-0:armhf libxcb-glx0:armhf libxcb-present0:armhf libxcb-randr0:armhf libxcb-sync1:armhf libxcb-xfixes0:armhf libxshmfence1:armhf libxxf86vm1:armhf libgl1-mesa-dri:armhf libgl1:armhf qjoypad libxrandr2:armhf libxcomposite1:armhf xtightvncviewer xvfb >> "$LOG_FILE" 2>&1

echo "[$(date)] Downloading Wine i386 packages" >> "$LOG_FILE"
wget https://dl.winehq.org/wine-builds/debian/dists/bookworm/main/binary-i386/wine-stable-i386_8.0.2~bookworm-1_i386.deb >> "$LOG_FILE" 2>&1
echo "[$(date)] Extracting first Wine package" >> "$LOG_FILE"
dpkg-deb -xv wine-stable-i386_8.0.2~bookworm-1_i386.deb /root/wine-installer >> "$LOG_FILE" 2>&1
rm wine-stable-i386_8.0.2~bookworm-1_i386.deb >> "$LOG_FILE" 2>&1

echo "[$(date)] Downloading second Wine package" >> "$LOG_FILE"
wget https://dl.winehq.org/wine-builds/debian/dists/bookworm/main/binary-i386/wine-stable_8.0.2~bookworm-1_i386.deb >> "$LOG_FILE" 2>&1
echo "[$(date)] Extracting second Wine package" >> "$LOG_FILE"
dpkg-deb -xv wine-stable_8.0.2~bookworm-1_i386.deb /root/wine-installer >> "$LOG_FILE" 2>&1
rm wine-stable_8.0.2~bookworm-1_i386.deb >> "$LOG_FILE" 2>&1

echo "[$(date)] Moving Wine files to final location" >> "$LOG_FILE"
mv /root/wine-installer/opt/wine-stable /root/wine >> "$LOG_FILE" 2>&1
rm -rf /root/wine-installer >> "$LOG_FILE" 2>&1

echo "[$(date)] Creating Wine wrapper scripts" >> "$LOG_FILE"
echo '#!/bin/bash' > /usr/local/bin/wine
echo 'box86 /root/wine/bin/wine "$@"' >> /usr/local/bin/wine
chmod +x /usr/local/bin/wine >> "$LOG_FILE" 2>&1

echo '#!/bin/bash' > /usr/local/bin/wineboot
echo 'box86 /root/wine/bin/wineboot "$@"' >> /usr/local/bin/wineboot
chmod +x /usr/local/bin/wineboot >> "$LOG_FILE" 2>&1

echo '#!/bin/bash' > /usr/local/bin/winecfg
echo 'box86 /root/wine/bin/winecfg "$@"' >> /usr/local/bin/winecfg
chmod +x /usr/local/bin/winecfg >> "$LOG_FILE" 2>&1

echo '#!/bin/bash' > /usr/local/bin/wineserver
echo 'box86 /root/wine/bin/wineserver "$@"' >> /usr/local/bin/wineserver
chmod +x /usr/local/bin/wineserver >> "$LOG_FILE" 2>&1

echo "[$(date)] Downloading and installing Winetricks" >> "$LOG_FILE"
wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks >> "$LOG_FILE" 2>&1
chmod +x winetricks && mv winetricks /usr/local/bin/ >> "$LOG_FILE" 2>&1

echo "[$(date)] Cloning box86 repository" >> "$LOG_FILE"
git clone https://github.com/ptitSeb/box86 >> "$LOG_FILE" 2>&1
cd box86 >> "$LOG_FILE" 2>&1
echo "[$(date)] Building box86" >> "$LOG_FILE"
mkdir build; cd build; cmake .. -DA64=1 -DARM_DYNAREC=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo >> "$LOG_FILE" 2>&1
make -j1 >> "$LOG_FILE" 2>&1
make install >> "$LOG_FILE" 2>&1
echo "[$(date)] Restarting systemd-binfmt" >> "$LOG_FILE"
systemctl restart systemd-binfmt >> "$LOG_FILE" 2>&1
cd ../.. >> "$LOG_FILE" 2>&1
rm -rf box86 >> "$LOG_FILE" 2>&1

echo "[$(date)] Building FreeType font engine" >> "$LOG_FILE"
wget https://download.savannah.gnu.org/releases/freetype/freetype-2.10.1.tar.gz >> "$LOG_FILE" 2>&1
tar xf freetype-2.10.1.tar.gz >> "$LOG_FILE" 2>&1
cd freetype-2.10.1 >> "$LOG_FILE" 2>&1
./configure --host=arm-linux-gnueabihf --prefix=/usr >> "$LOG_FILE" 2>&1
make -j4 >> "$LOG_FILE" 2>&1
make install >> "$LOG_FILE" 2>&1
cd .. >> "$LOG_FILE" 2>&1
rm -rf freetype* >> "$LOG_FILE" 2>&1

echo "[$(date)] Setting display for X server" >> "$LOG_FILE"
export DISPLAY=:0

echo "[$(date)] Initializing Wine environment" >> "$LOG_FILE"
rm -rf /root/.wine >> "$LOG_FILE" 2>&1
WINEPREFIX="/root/.wine"
export WINEPREFIX="/root/.wine"
export WINEDEBUG=-all
export WINE_MONO_SILENT_INSTALL=1
export WINE_GECKO_SILENT_INSTALL=1
export BOX86_LD_LIBRARY_PATH=/usr/lib/arm-linux-gnueabihf/
export BOX86_GL=1
export BOX86_VULKAN=1

echo "[$(date)] Running Wine boot initialization" >> "$LOG_FILE"
wine wineboot --init >> "$LOG_FILE" 2>&1

echo "[$(date)] Configuring Wine settings" >> "$LOG_FILE"
wine reg add "HKEY_CURRENT_USER\Software\Wine\Version" /v Windows /t REG_SZ /d "winxp" /f >> "$LOG_FILE" 2>&1
wine reg add "HKEY_LOCAL_MACHINE\System\MountPoints2\D:" /v "Path" /t REG_SZ /d "/mnt/sdcard/wine/d" /f >> "$LOG_FILE" 2>&1

echo "[$(date)] Updating drives configuration" >> "$LOG_FILE"
cat > "$WINEPREFIX/system.reg" << EOF
WINE REGISTRY Version 2
;; All keys relative to \\\\REGISTRY\\\\MACHINE\\\\Software\\\\Wine\\\\
win
[System\\\\MountPoints2\\\\D:]
"Path"="/mnt/sdcard/wine/d"
EOF

ln -sf /mnt/sdcard/wine/d "$WINEPREFIX/dosdevices/d:" >> "$LOG_FILE" 2>&1

echo "[$(date)] Forcing Wine configuration update" >> "$LOG_FILE"
wine wineboot -u >> "$LOG_FILE" 2>&1

echo "[$(date)] Killing remaining Wine processes" >> "$LOG_FILE"
wineserver -k >> "$LOG_FILE" 2>&1

echo "[$(date)] Installing Winetricks components" >> "$LOG_FILE"
winetricks d3dx9 vb6run >> "$LOG_FILE" 2>&1

echo "[$(date)] Installing WineMono components" >> "$LOG_FILE"
wget https://dl.winehq.org/wine/wine-mono/9.4.0/wine-mono-9.4.0-x86.msi --no-check-certificate
wine msiexec /i wine-mono-9.4.0-x86.msi
rm wine-mono-9.4.0-x86.msi

echo "[$(date)] Creating QJoyPad configuration" >> "$LOG_FILE"
mkdir -p /root/.qjoypad3 >> "$LOG_FILE" 2>&1

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

echo "[$(date)] Copying QJoyPad configuration" >> "$LOG_FILE"
cp -r /root/.qjoypad3 /.qjoypad3 >> "$LOG_FILE" 2>&1

echo "[$(date)] Creating Wine recovery archive" >> "$LOG_FILE"
XZ_OPT=-9 tar -Jcvf /root/wine.recovery.tar.xz /root/.wine >> "$LOG_FILE" 2>&1

echo "[$(date)] Creating Wine launch script" >> "$LOG_FILE"
cat > $SCRIPT_DIR/wine_desktop.sh << 'EOL'
#!/bin/bash
cd /root

echo "[$(date)] Starting wine startup script" >> /tmp/wine_startup.log

echo "[$(date)] Killing any existing X server processes" >> /tmp/wine_startup.log
pkill Xorg >> /tmp/wine_startup.log 2>&1
pkill startx >> /tmp/wine_startup.log 2>&1

echo "[$(date)] Setting WINEPREFIX to /root/.wine" >> /tmp/wine_startup.log
export WINEPREFIX=/root/.wine

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

echo "[$(date)] Starting X server" >> /tmp/wine_startup.log
export LANGUAGE=en_US
export LANG=en_US
export STARTUP="wine explorer.exe /desktop=shell,640x480"
startx >> /tmp/wine_startup.log 2>&1

echo "[$(date)] Xorg exited, cleaning up processes" >> /tmp/wine_startup.log

# Make sure to clean up the monitor process when the script exits
trap "kill $MONITOR_PID 2>/dev/null" EXIT
killall qjoypad >> /tmp/wine_startup.log 2>&1

echo "[$(date)] Script completed" >> /tmp/wine_startup.log
EOL

echo "[$(date)] Creating 1280x960 Wine launch script" >> "$LOG_FILE"
cat > $SCRIPT_DIR/wine_desktop_1280x960.sh << 'EOL'
#!/bin/bash
cd /root

echo "[$(date)] Starting wine startup script" >> /tmp/wine_startup.log

pkill -f Xvfb
pkill -f x11vnc
pkill -f qjoypad
pkill -f vncviewer

Xvfb :1 -screen 0 1280x960x24 &
sleep 3
x11vnc -display :1 -forever -noshm -listen 0.0.0.0 -scale 0.5 &
sleep 10
export DISPLAY=:0
export STARTUP="vncviewer 0.0.0.0:0 -fullscreen"

# Function to check if qjoypad is running
is_qjoypad_running() {
    pgrep -x qjoypad >/dev/null
}

# Start the monitor process
(
    export DISPLAY=:0
    while true; do
        if ! is_qjoypad_running; then
            qjoypad default &
        fi
        sleep 5
    done
) &

# Store the monitor process ID
MONITOR_PID=$!

startx &

DISPLAY=:1 wine explorer.exe /desktop=shell,1280x960

pkill -f vncviewer

echo "[$(date)] Script completed" >> /tmp/wine_startup.log
EOL

echo "[$(date)] Creating 1024x768 Wine launch script" >> "$LOG_FILE"
cat > $SCRIPT_DIR/wine_desktop_1024x768.sh << 'EOL'
#!/bin/bash
cd /root

echo "[$(date)] Starting wine startup script" >> /tmp/wine_startup.log

pkill -f Xvfb
pkill -f x11vnc
pkill -f qjoypad
pkill -f vncviewer

Xvfb :1 -screen 0 1024x768x24 &
sleep 3
x11vnc -display :1 -forever -noshm -listen 0.0.0.0 -scale 0.625 &
sleep 10
export DISPLAY=:0
export STARTUP="vncviewer 0.0.0.0:0 -fullscreen"

# Function to check if qjoypad is running
is_qjoypad_running() {
    pgrep -x qjoypad >/dev/null
}

# Start the monitor process
(
    export DISPLAY=:0
    while true; do
        if ! is_qjoypad_running; then
            qjoypad default &
        fi
        sleep 5
    done
) &

# Store the monitor process ID
MONITOR_PID=$!

startx &

DISPLAY=:1 wine explorer.exe /desktop=shell,1024x768

pkill -f vncviewer

echo "[$(date)] Script completed" >> /tmp/wine_startup.log
EOL

echo start \"\" \"c:\\windows\\explorer.exe\" > "/root/.wine/drive_c/ProgramData/Microsoft/Windows/Start Menu/explorer.bat"

cat > $SCRIPT_DIR/wine_mount_isos.sh << 'EOL'
#!/bin/bash

cd /root

LOG_FILE="/tmp/wine_mount.log"

echo "[$(date)] Starting Wine ISO mount script" >> "$LOG_FILE"

# Cleanup/Unmount section
if [ -d "/root/virtualdrive" ]; then
    echo "[$(date)] Starting cleanup of existing mounts" >> "$LOG_FILE"
    
    # Unmount all drives
    umount /root/virtualdrive/Drive* 2>> "$LOG_FILE"
    echo "[$(date)] Unmounted existing drives" >> "$LOG_FILE"

    # Remove mount points
    rm -rf /root/virtualdrive/Drive*
    echo "[$(date)] Removed mount points" >> "$LOG_FILE"

    # Remove existing Wine drive mappings and symlinks
    DOSDEVICES="/root/.wine/dosdevices"
    WINEPREFIX="/root/.wine"
    
    for drive in "$DOSDEVICES"/*:; do
        if [ -L "$drive" ]; then  # If it's a symlink
            letter=$(basename "$drive" | cut -d':' -f1)
            # Skip c:, d:, and z: drives
            if [[ "$letter" != "c" && "$letter" != "d" && "$letter" != "z" ]]; then
                wine reg delete "HKEY_LOCAL_MACHINE\\Software\\Wine\\Drives" /v "${letter}:" /f 2>> "$LOG_FILE"
                rm -f "$drive"
                echo "[$(date)] Removed Wine drive mapping for ${letter}:" >> "$LOG_FILE"
            fi
        fi
    done
fi

# Mount section
if [ -d "/mnt/sdcard/wine/isos" ]; then
    echo "[$(date)] Starting mount of ISOs" >> "$LOG_FILE"
    
    ISO_DIR="/mnt/sdcard/wine/isos"
    MOUNT_BASE="/root/virtualdrive"
    DOSDEVICES="/root/.wine/dosdevices"

    mkdir -p "$MOUNT_BASE"
    echo "[$(date)] Created mount base directory: $MOUNT_BASE" >> "$LOG_FILE"

    # Counter for drive letters (starting from e:)
    drive_letter=101  # 101 corresponds to 'e' in ASCII

    for iso in "$ISO_DIR"/*.iso; do
        if [ -f "$iso" ]; then
            filename=$(basename "$iso")
            mount_point="$MOUNT_BASE/Drive$drive_letter"
            mkdir -p "$mount_point"
            echo "[$(date)] Created mount point: $mount_point" >> "$LOG_FILE"

            mount -o loop "$iso" "$mount_point"
            
            if [ $? -eq 0 ]; then
                # Convert drive_letter number to lowercase letter (101->e, 102->f, etc.)
                letter=$(printf \\$(printf '%03o' $drive_letter))
                
                # Add drive to Wine configuration
                WINEPREFIX="/root/.wine"
                wine reg add "HKEY_LOCAL_MACHINE\\Software\\Wine\\Drives" /v "${letter}:" /t REG_SZ /d "cdrom:$mount_point" /f 2>> "$LOG_FILE"

                # Create symlink in dosdevices
                ln -sf "$mount_point" "$DOSDEVICES/${letter}:"
                
                echo "[$(date)] Successfully mounted $filename to $mount_point as ${letter}:" >> "$LOG_FILE"
                
                ((drive_letter++))
            else
                echo "[$(date)] Failed to mount $filename" >> "$LOG_FILE"
                rmdir "$mount_point"
            fi
        fi
    done
else
    echo "[$(date)] ISO directory not found: /mnt/sdcard/wine/isos" >> "$LOG_FILE"
fi

echo "[$(date)] Wine ISO mount script completed" >> "$LOG_FILE"
EOL

echo "[$(date)] Wine installation completed" >> "$LOG_FILE"
