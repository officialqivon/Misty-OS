#!/usr/bin/env bash
set -eoux pipefail

# Remove unnecessary packages to slim down the ISO
dnf remove -y google-noto-fonts-all || true

# Install Anaconda Web UI for the installer
dnf install -y anaconda-live anaconda-webui

# Enable the Web UI installer
systemctl enable anaconda-web-ui.service || true
