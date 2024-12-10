# Wine Installation Script for RG35XX Plus

This script automates the installation and configuration of Wine on the RG35XX Plus, allowing you to run Windows applications and games on your device.

## Features

- Configures Wine with optimal settings for the RG35XX Plus
- Installs Box86 for x86 emulation
- Sets up QJoyPad for gamepad support
- Configures display settings for the device's screen
- Maps the SD card to Wine's D: drive
- Includes Winetricks with D3DX9 support
- Creates automatic recovery backup of Wine configuration

## Prerequisites

- RG35XX Plus running stock OS
- Internet connection for downloading packages
- Sufficient storage space (approximately 1GB)

## Installation

1. Copy the script to your device
2. Run the script as root
3. Wait for the installation to complete (may take 15-30 minutes)

## Usage

After installation, you can launch Wine through:
```
/mnt/mmc/Roms/APPS/wine.sh
```

The script will:
- Start an X server
- Launch QJoyPad for controller support
- Open Wine Explorer

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
- Select: Backspace?
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
