#!/bin/bash
# install_dcpj125.sh - Installer for Brother DCP-J125 on Debian/Ubuntu-based systems
#
# Copyright (c) 2025 Leonie <me@koyu.space>
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the “Software”), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e

echo "👉 Brother DCP-J125 Installer is starting..."

# 1. Enable 32-bit support
echo "🔧 Enabling i386 support..."
sudo dpkg --add-architecture i386
sudo apt update

echo "📦 Installing necessary 32-bit libraries..."
sudo apt install -y libc6:i386 libstdc++6:i386

# Check if we're on x86_64 and install lib32-libcups if available
if [[ "$(uname -m)" == "x86_64" ]]; then
    echo "🔧 Detected x86_64 system, checking for lib32-libcups..."
    if apt-cache show lib32-libcups >/dev/null 2>&1; then
        sudo apt install -y lib32-libcups
        echo "✅ lib32-libcups installed"
    else
        echo "ℹ️  lib32-libcups not available in repositories, continuing..."
    fi
fi

# 2. Prepare working directory
WORKDIR=~/brother-dcpj125
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# 3. Download drivers
echo "⬇️ Downloading Brother drivers..."
wget -q https://download.brother.com/welcome/dlf005583/dcpj125lpr-1.1.3-1.i386.deb
wget -q https://download.brother.com/welcome/dlf005585/dcpj125cupswrapper-1.1.3-1.i386.deb

# 4. Install drivers
echo "📦 Installing Brother LPR driver..."
sudo dpkg -i dcpj125lpr-1.1.3-1.i386.deb || sudo apt --fix-broken install -y

echo "📦 Installing Brother CUPS wrapper..."
sudo dpkg -i dcpj125cupswrapper-1.1.3-2.i386.deb || sudo apt --fix-broken install -y

# 5. Configure printer
echo "🖨 Configuring printer..."
DEVICE_URI=$(lpinfo -v | grep -i brother | head -n1 | awk '{print $2}')
if [ -z "$DEVICE_URI" ]; then
    echo "❌ No Brother printer found. Please make sure it is connected via USB."
    exit 1
fi

sudo lpadmin -p DCPJ125 -E -v "$DEVICE_URI" -P /usr/share/ppd/Brother/brother_dcpj125_printer_en.ppd

echo "✅ Printer DCPJ125 has been added."

# Fix CUPS wrapper for systemd systems
echo "🔧 Fixing CUPS wrapper for systemd compatibility..."
if [ -f "/opt/brother/Printers/dcpj125/cupswrapper/cupswrapperdcpj125" ]; then
    sudo sed -i 's|/etc/init.d/cups|/etc/rc.d/cupsd|' "/opt/brother/Printers/dcpj125/cupswrapper/cupswrapperdcpj125"
    echo "✅ CUPS wrapper fixed for systemd"
    
    # Execute CUPS wrapper as recommended by Brother
    echo "🔧 Executing CUPS wrapper..."
    sudo /opt/brother/Printers/dcpj125/cupswrapper/cupswrapperdcpj125
    echo "✅ CUPS wrapper executed successfully"
else
    echo "⚠️  CUPS wrapper not found at expected location"
fi

# Add current user to lp group
echo "👤 Adding user to lp group..."
sudo gpasswd -a "$USER" lp
echo "✅ User $USER added to lp group"

# 6. Print test page (optional)
read -rp "📄 Print test page? (y/n): " TESTPAGE
if [[ "$TESTPAGE" =~ ^[Yy]$ ]]; then
    echo "🖨 Printing test page..."
    lp -d DCPJ125 /usr/share/cups/data/testprint
fi

echo "🎉 Brother DCP-J125 is ready to use!"

echo ""
echo "📋 IMPORTANT NOTES:"
echo "   ✅ User $USER has been added to the 'lp' group"
echo "   ⚠️  You need to LOG OUT and LOG BACK IN for group changes to take effect"
echo "   ✅ CUPS wrapper has been executed"
echo "   ℹ️  If you encounter issues, try restarting the CUPS service:"
echo "       sudo systemctl restart cups"