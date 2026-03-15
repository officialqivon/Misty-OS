#!/usr/bin/env bash
set -oux pipefail

# Install Anaconda and yad for the welcome dialog
dnf install -y anaconda-live anaconda-webui firefox yad --allowerasing

# Write Anaconda profile
mkdir -p /etc/anaconda/profile.d/
cat > /etc/anaconda/profile.d/mistyos.conf << 'EOF'
[Profile]
profile_id = mistyos

[Profile Detection]
os_id = fedora

[Network]
default_on_boot = FIRST_WIRED_WITH_LINK

[Storage]
default_scheme = BTRFS
EOF

# Write kickstart pointing at MistyOS image
cat > /usr/share/anaconda/interactive-defaults.ks << 'EOF'
%pre
ostreecontainer --url ghcr.io/officialqivon/mistyos:latest --transport registry --no-signature-verification
%end
EOF

# Create the welcome/install launcher script
cat > /usr/bin/mistyos-welcome.sh << 'EOF'
#!/bin/bash
while true; do
    choice=$(yad --center --title="Welcome to MistyOS" \
        --text="Welcome to MistyOS!\nWhat would you like to do?" \
        --button="Install MistyOS:0" \
        --button="Try Without Installing:1" \
        --button="Quit:2" \
        --width=400 --height=200)
    ret=$?
    if [ $ret -eq 0 ]; then
        liveinst
    elif [ $ret -eq 1 ]; then
        break
    elif [ $ret -eq 2 ]; then
        break
    fi
done
EOF
chmod +x /usr/bin/mistyos-welcome.sh

# Autostart the welcome script on login
mkdir -p /etc/xdg/autostart
cat > /etc/xdg/autostart/mistyos-welcome.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=MistyOS Welcome
Exec=/usr/bin/mistyos-welcome.sh
X-GNOME-Autostart-enabled=true
EOF
