#!/bin/bash
# HyperOS Essential App Restorer (macOS Port)
# Restores critical system apps that may have been accidentally removed

# ANSI Colors
GREEN="\033[92m"
CYAN="\033[96m"
RESET="\033[0m"

# Apps to restore
apps=(
    "com.miui.gallery"
    "com.miui.securitycenter"
    "com.lbe.security.miui"
    "com.miui.securityadd"
    "com.miui.permission"
    "com.android.providers.media.module"
    "com.android.providers.media"
    "com.android.settings"
)

# Check for ADB
if [[ -f "./adb" ]]; then
    ADB_CMD="./adb"
elif command -v adb &> /dev/null; then
    ADB_CMD="adb"
else
    echo "ERROR: ADB not found. Please install ADB or place it in this folder."
    echo "Install via Homebrew: brew install android-platform-tools"
    exit 1
fi

echo ""
printf "${GREEN}===================================================${RESET}\n"
printf "${GREEN} HyperOS Essential App Restorer${RESET}\n"
printf "${GREEN}===================================================${RESET}\n"

# Check device connection
device=$($ADB_CMD devices | grep -v "List" | grep -v "^$" | head -1 | awk '{print $1}')
if [[ -z "$device" ]]; then
    echo ""
    echo "ERROR: No device connected. Please connect your device and enable USB debugging."
    exit 1
fi

echo ""
echo "Device connected: $device"
echo ""

for app in "${apps[@]}"; do
    printf "\n${CYAN}Attempting to restore: $app${RESET}\n"
    
    # The standard restore command with explicit user 0 targeting
    $ADB_CMD shell pm install-existing --user 0 "$app" 2>/dev/null || true
    
    # Enable the package
    $ADB_CMD shell pm enable --user 0 "$app" 2>/dev/null || true
done

echo ""
printf "${GREEN}===================================================${RESET}\n"
printf "${GREEN} Restoration commands complete. Please restart device.${RESET}\n"
printf "${GREEN}===================================================${RESET}\n"
echo ""
