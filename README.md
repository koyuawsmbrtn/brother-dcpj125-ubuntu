# Brother DCP-J125 Ubuntu Installer

A simple installer script for setting up the Brother DCP-J125 printer on Debian/Ubuntu-based systems.

## Overview

This script automates the installation and configuration of the Brother DCP-J125 printer on Ubuntu and other Debian-based Linux distributions. It handles downloading the necessary drivers, installing dependencies, and configuring the printer for immediate use.

## Features

- ✅ Automatic 32-bit architecture support setup
- ✅ Downloads and installs official Brother drivers
- ✅ Configures printer automatically
- ✅ Optional test page printing
- ✅ Error handling and dependency resolution
- ✅ User-friendly progress indicators

## Prerequisites

- Ubuntu/Debian-based Linux distribution
- Brother DCP-J125 printer connected via USB
- Internet connection for downloading drivers
- `sudo` privileges

## Installation

1. Clone or download this repository:
   ```bash
   git clone <repository-url>
   cd brother-dcpj125-ubuntu
   ```

2. Make the script executable:
   ```bash
   chmod +x install_dcpj125.sh
   ```

3. Run the installer:
   ```bash
   ./install_dcpj125.sh
   ```

## What the Script Does

1. **Enables i386 Architecture**: Adds 32-bit support required for Brother drivers
2. **Installs Dependencies**: Installs necessary 32-bit libraries (`libc6:i386`, `libstdc++6:i386`)
3. **x86_64 Support**: On 64-bit systems, attempts to install `lib32-libcups` if available
4. **Downloads Drivers**: Fetches the official Brother LPR and CUPS wrapper drivers
5. **Installs Drivers**: Installs both driver packages with automatic dependency resolution
6. **Configures Printer**: Automatically detects and configures the Brother DCP-J125
7. **Executes CUPS Wrapper**: Runs the required Brother CUPS wrapper executable
8. **User Group Setup**: Adds the current user to the 'lp' group for printer access
9. **Test Print**: Offers to print a test page to verify installation

## Important Post-Installation Steps

⚠️ **LOGOUT AND LOGIN REQUIRED**: After installation, you must log out and log back in for the group changes to take effect. The script adds your user to the 'lp' group, which is necessary for printer access.

## Troubleshooting

### Printer Not Detected
- Ensure the Brother DCP-J125 is connected via USB
- Check that the printer is powered on
- Try disconnecting and reconnecting the USB cable
- Make sure you've logged out and back in after installation (required for group permissions)

### Installation Fails
- Make sure you have internet connectivity
- Verify you have `sudo` privileges
- Check if the printer is already configured with `lpstat -p`

### Driver Issues
- The script uses official Brother drivers version 1.1.3
- If drivers fail to install, try running `sudo apt --fix-broken install`
- On x86_64 systems, ensure `lib32-libcups` is installed if available

### Permission Issues
- Ensure your user is in the 'lp' group: `groups $USER | grep lp`
- If not in the group, run: `sudo gpasswd -a $USER lp`
- **Log out and log back in** after adding to the group
- Restart CUPS service if needed: `sudo systemctl restart cups`

## Manual Printer Management

After installation, you can manage your printer using standard Linux tools:

```bash
# Check printer status
lpstat -p DCPJ125

# Print a document
lp -d DCPJ125 /path/to/document.pdf

# Remove printer (if needed)
sudo lpadmin -x DCPJ125
```

## Supported Systems

This installer has been tested on:
- Ubuntu 20.04 LTS and newer
- Debian 10 and newer
- Linux Mint 20 and newer
- KDE neon 5.24 and newer

## Files Created

The script creates a working directory at `~/brother-dcpj125` and downloads:
- `dcpj125lpr-1.1.3-1.i386.deb` - Brother LPR driver
- `dcpj125cupswrapper-1.1.3-2.i386.deb` - Brother CUPS wrapper

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

Created by Leonie <me@koyu.space>

## Contributing

Feel free to submit issues and enhancement requests!

## Acknowledgments

- Brother Industries for providing Linux drivers
- The CUPS printing system developers
