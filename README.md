# Wine Installation Script for RG35XX Plus

This script automates the installation and configuration of Wine on the RG35XX Plus, allowing you to run Windows applications and games on your device.

## Tested
- Fallout 1 ✅
- Fallout 2 🐢
- Diablo 2 ✅
- Starcraft ✅
- Warcraft 3 ⚠️
- Sim City 3000 Unlimited ✅

> [!WARNING]
>  This is a preview build intended for tinkerers comfortable with Wine. Due to the complexity, it may not progress beyond this stage. Not everything will be plug-and-play due to Wine limitations.

> [!NOTE]
> 2024-12-11 updates
> 
> Added scripts for the following desktop resolutions to enhance game compatibility
> - 800x600
> - 1024x768
> - 1280x960
> 
> 2024-12-10 updates
> 
> - Automatic ISO mounting /mnt/sdcard/wine/isos (wine_mount_isos.sh)
> - Changed D root to /mnt/mmc/sdcard/wine/d
> - Fixed language (text) issues
> - Removed intermediate terminal screen, now boots directly into shell

## Features

- Configures Wine with optimal settings for the RG35XX Plus
- Installs Box86 for x86 emulation
- Sets up QJoyPad for gamepad support
- Configures display settings for the device's screen
- Maps the SD card to Wine's D: drive
- Includes Winetricks with D3DX9 support
- Creates automatic recovery backup of Wine configuration

## Prerequisites

- RG35XX+ (or variant) running stock OS
- Internet connection for downloading packages
- Sufficient storage space (approximately 1GB)

## Installation

> [!WARNING]
> You MUST be connected to the internet before beginning installation!

1. Copy the script to your device
2. Run the script as root
3. Wait for the installation to complete

> [!NOTE]
> Installation process can take 90-120 minutes depending on your internet connection. This will be reduced for future versions

## Usage

After installation, you can launch Wine through:
```
/mnt/mmc/Roms/APPS/wine_desktop.sh
```
Any ISO's within the directory /mnt/sdcard/wine/isos can be mounted by calling
```
/mnt/mmc/Roms/APPS/wine_mount_isos.sh
```

The script will:
- Start an X server
- Launch QJoyPad for controller support
- Open Wine Explorer

> [!NOTE]
> Users should be comfortable with Wine and Winetricks if they want to install additional software or modify configurations.

## Known Issues

> [!WARNING]
> 
> - Improper shutdown can cause Wine to corrupt its configuration files, requiring a restore from backup
> - Some applications may require manual Winetricks configuration
> - Wine shell closes once the last application exits. This is apparently a limitation of WINE itself, so unfortunately I can't do anything about it

## Controller Mapping

The default controller mapping is configured as follows:
- D-Pad: Mouse movement
- A: A
- B: B
- X: X
- Y: Y
- L1: Left Mouse Click
- R1: Right Mouse Click
- L2: Scroll Down
- R2: Scroll Up
- Menu: Escape
- Select: Backspace
- Start: Enter

## Troubleshooting

If Wine fails to start:
1. Check `/tmp/wine_startup.log` for error messages
2. Restore Wine configuration from `/root/wine.recovery.tar.xz`
3. Ensure sufficient storage space is available

## Notes

- Windows XP mode is enabled by default for maximum compatibility
- Display resolution is set to 640x480
- Wine debug messages are disabled for better performance

## Limitations

- Not all Windows applications will work due to hardware limitations
- Performance may vary depending on the application
- Some 3D applications may not function properly
