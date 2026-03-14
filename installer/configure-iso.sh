#!/usr/bin/env bash
set -oux pipefail

# Install Anaconda Web UI installer
dnf install -y anaconda-live anaconda-webui firefox --allowerasing

# Write Anaconda profile for MistyOS
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

# Write kickstart defaults pointing at your image
cat > /usr/share/anaconda/interactive-defaults.ks << 'EOF'
%pre
ostreecontainer --url ghcr.io/officialqivon/mistyos:latest --transport registry --no-signature-verification
%end
EOF

# Autostart the installer on login
mkdir -p /etc/xdg/autostart
cat > /etc/xdg/autostart/anaconda.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=MistyOS Installer
Exec=anaconda
EOF
