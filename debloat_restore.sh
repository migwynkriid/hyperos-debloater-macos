#!/bin/bash
# HyperOS Essential App Restorer - macOS/Linux Version

# Colors
GREEN='\033[0;92m'
CYAN='\033[0;96m'
RESET='\033[0m'

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

echo -e "${GREEN}===================================================${RESET}"
echo -e "${GREEN} HyperOS Essential App Restorer${RESET}"
echo -e "${GREEN}===================================================${RESET}"

for app in "${apps[@]}"; do
    echo -e "\n${CYAN}Attempting to restore: $app${RESET}"
    
    # The standard restore command with explicit user 0 targeting
    adb shell pm install-existing --user 0 "$app"
    
    # Enable the package
    adb shell pm enable --user 0 "$app"
done

echo -e "\n${GREEN}===================================================${RESET}"
echo -e "${GREEN} Restoration commands complete. Please restart device.${RESET}"
echo -e "${GREEN}===================================================${RESET}"
