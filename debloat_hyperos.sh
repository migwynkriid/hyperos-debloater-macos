#!/bin/bash
# Xiaomi HyperOS Debloat Commander v17.1 - macOS/Linux Version
# A powerful, interactive, and completely reversible utility to safely remove bloatware

set -e

# Colors
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
CYAN='\033[0;96m'
MAGENTA='\033[0;95m'
WHITE='\033[0;97m'
GRAY='\033[0;90m'
RESET='\033[0m'
BOLD='\033[1m'

# Background colors
BG_CYAN='\033[46m\033[30m'
BG_GREEN='\033[42m\033[30m'
BG_YELLOW='\033[43m\033[30m'
BG_RED='\033[41m\033[97m'
BG_MAGENTA='\033[45m\033[30m'

# App lists
apps_p1="com.miui.analytics com.miui.systemAdSolution com.miui.msa.global com.miui.daemon com.facebook.appmanager com.facebook.services com.facebook.system com.facebook.katana com.miui.cleanmaster com.miui.miservice com.miui.touchassistant com.miui.hybrid com.miui.hybrid.accessory com.xiaomi.discover com.xiaomi.ab com.miui.cit com.miui.wmsvc com.miui.userguide com.miui.backup com.xiaomi.xmsf com.mi.global.bbs com.mi.global.shop com.miui.nextpay com.miui.tsmclient com.miui.greenguard com.xiaomi.gamecenter com.xiaomi.gamecenter.sdk.service com.miui.uireporter com.miui.securityadd com.baidu.input_mi com.iflytek.inputmethod.miui com.sohu.inputmethod.sogou.xiaomi com.tencent.soter.soterserver com.bsp.catchlog com.xiaomi.security.onetrack com.wapi.wapicertmanage com.miui.newmidrive com.xiaomi.aireco com.qti.qualcomm.deviceinfo com.unionpay.tsmservice.mi com.miui.guardprovider com.miui.powerinsight com.miui.yellowpage com.xiaomi.pass com.mipay.wallet"

apps_p2="com.miui.compass com.miui.weather2 com.miui.notes com.miui.calculator com.miui.videoplayer com.miui.player com.xiaomi.glgm com.miui.gallery com.xiaomi.midrop com.miui.fmservice com.miui.fm com.android.stk com.xiaomi.payment com.xiaomi.vipaccount com.duokan.phone.remotecontroller com.xiaomi.smarthome com.android.calendar com.miui.calendar com.android.deskclock com.android.providers.downloads.ui com.android.fileexplorer com.mi.android.globalFileexplorer com.android.soundrecorder com.android.email com.miui.screenrecorder com.miui.huanji com.android.browser com.miui.browser cn.wps.moffice_eng.xiaomi.lite com.miui.qr com.miui.mediaviewer com.miui.mediaeditor"

apps_p3="com.miui.personalassistant com.miui.appvault com.miui.themestore com.android.thememanager com.xiaomi.thememanager com.miui.findmy com.xiaomi.finddevice com.xiaomi.scanner com.miui.scanner com.xiaomi.market com.xiaomi.mipicks com.miui.securitycenter com.xiaomi.account com.miui.cloudservice com.miui.micloudsync com.miui.cloudbackup com.xiaomi.roaming com.miui.roaming"

apps_p4="com.miui.aod com.xiaomi.hypercomm com.miui.audiomonitor com.miui.voiceassistProxy com.xiaomi.aiasst.service com.xiaomi.aiasst.vision com.xiaomi.mibrain.speech com.xiaomi.metoknlp com.android.dreams.basic com.android.dreams.phototable com.android.printspooler com.android.bips com.android.bookmarkprovider com.android.traceur com.miui.contentextension com.miui.carlink com.miui.thirdappassistant com.xiaomi.aicr com.miui.misightservice com.xiaomi.barrage com.xiaomi.mirror com.miui.voiceassistoverlay"

apps_restore_only="com.miui.extraphoto com.miui.face com.android.egg com.miui.freeform com.miui.mishare.connectivity com.miui.phrase com.miui.vsimcore com.miui.virtualsim"

# Global variables
TARGET_ID=""
TARGET_MODEL=""
LOGFILE=""
MODE_NAME=""
MODE_VERB=""
CMD_ACTION=""
SKIP_NOT_INSTALLED=0

# Temp files
TEMP_DIR="/tmp/hyperos_debloater"
mkdir -p "$TEMP_DIR"

# Function to get app name
get_app_name() {
    local pkg="$1"
    case "$pkg" in
        "com.miui.analytics") echo "MIUI Analytics (Ad Tracking)" ;;
        "com.miui.systemAdSolution") echo "MIUI System Ad Solution" ;;
        "com.miui.msa.global") echo "MSA (Main System Ads Service)" ;;
        "com.miui.daemon") echo "MIUI Daemon (Data Collection)" ;;
        "com.xiaomi.discover") echo "Xiaomi Discover (Ads/Recommendations)" ;;
        "com.xiaomi.ab") echo "Xiaomi AB (Ads)" ;;
        "com.facebook.appmanager") echo "Facebook App Manager" ;;
        "com.facebook.services") echo "Facebook Services" ;;
        "com.facebook.system") echo "Facebook System Framework" ;;
        "com.facebook.katana") echo "Facebook App (Pre-installed)" ;;
        "com.mi.global.bbs") echo "Xiaomi Community" ;;
        "com.miui.cleanmaster") echo "Clean Master (Ads/Junk Cleaner)" ;;
        "com.miui.miservice") echo "Mi Services (Support/Ads)" ;;
        "com.miui.touchassistant") echo "Quick Ball (Touch Assistant)" ;;
        "com.miui.hybrid") echo "Quick Apps Service" ;;
        "com.miui.hybrid.accessory") echo "Quick Apps Accessory" ;;
        "com.miui.cit") echo "CIT (Hardware Test)" ;;
        "com.miui.wmsvc") echo "WM Service (Cloud Backups)" ;;
        "com.miui.userguide") echo "User Guide" ;;
        "com.miui.backup") echo "MIUI Backup" ;;
        "com.xiaomi.xmsf") echo "Xiaomi Service Framework" ;;
        "com.mi.global.shop") echo "Xiaomi Store" ;;
        "com.miui.nextpay") echo "Mi Pay Framework" ;;
        "com.miui.tsmclient") echo "Mi Pay Client" ;;
        "com.miui.greenguard") echo "Family Link / Kids Mode" ;;
        "com.xiaomi.gamecenter") echo "Xiaomi Game Center" ;;
        "com.xiaomi.gamecenter.sdk.service") echo "Xiaomi Game SDK" ;;
        "com.miui.uireporter") echo "MIUI UI Analytics" ;;
        "com.miui.securityadd") echo "MIUI Security Addons" ;;
        "com.baidu.input_mi") echo "Baidu Keyboard (Chinese)" ;;
        "com.iflytek.inputmethod.miui") echo "iFlyTek Keyboard" ;;
        "com.sohu.inputmethod.sogou.xiaomi") echo "Sogou Keyboard" ;;
        "com.tencent.soter.soterserver") echo "Tencent Soter Framework" ;;
        "com.bsp.catchlog") echo "BSP Catch Log" ;;
        "com.xiaomi.security.onetrack") echo "Xiaomi OneTrack (Telemetry)" ;;
        "com.wapi.wapicertmanage") echo "WAPI Certificate Manage" ;;
        "com.miui.newmidrive") echo "Xiaomi Cloud Drive" ;;
        "com.xiaomi.aireco") echo "Xiaomi AI Recommendations" ;;
        "com.qti.qualcomm.deviceinfo") echo "Qualcomm Device Info" ;;
        "com.unionpay.tsmservice.mi") echo "UnionPay TSM Service" ;;
        "com.miui.guardprovider") echo "MIUI Guard Provider" ;;
        "com.miui.powerinsight") echo "MIUI Power Insight" ;;
        "com.miui.yellowpage") echo "MIUI Yellow Pages" ;;
        "com.xiaomi.pass") echo "Xiaomi Pass" ;;
        "com.mipay.wallet") echo "Xiaomi Wallet" ;;
        "com.miui.compass") echo "Mi Compass" ;;
        "com.miui.weather2") echo "Mi Weather" ;;
        "com.miui.notes") echo "Mi Notes" ;;
        "com.miui.calculator") echo "Mi Calculator" ;;
        "com.miui.videoplayer") echo "Mi Video" ;;
        "com.miui.player") echo "Mi Music" ;;
        "com.xiaomi.glgm") echo "Xiaomi Games" ;;
        "com.miui.gallery") echo "Mi Gallery" ;;
        "com.miui.fmservice") echo "FM Radio Service" ;;
        "com.miui.fm") echo "FM Radio App" ;;
        "com.android.stk") echo "SIM Toolkit" ;;
        "com.xiaomi.midrop") echo "Mi Drop (Share)" ;;
        "com.xiaomi.payment") echo "Mi Pay / Wallet" ;;
        "com.xiaomi.vipaccount") echo "Xiaomi VIP Account" ;;
        "com.duokan.phone.remotecontroller") echo "Mi Remote" ;;
        "com.xiaomi.smarthome") echo "Xiaomi Home" ;;
        "com.android.calendar") echo "Xiaomi Calendar" ;;
        "com.miui.calendar") echo "Xiaomi Calendar (Alt)" ;;
        "com.android.deskclock") echo "Xiaomi Clock" ;;
        "com.android.providers.downloads.ui") echo "Downloads App" ;;
        "com.mi.android.globalFileexplorer") echo "File Manager" ;;
        "com.android.fileexplorer") echo "File Manager (Alt)" ;;
        "com.android.soundrecorder") echo "Sound Recorder" ;;
        "com.android.email") echo "Xiaomi Email App" ;;
        "com.miui.screenrecorder") echo "Screen Recorder" ;;
        "com.miui.huanji") echo "Mi Mover" ;;
        "com.android.browser") echo "Mi Browser" ;;
        "com.miui.browser") echo "Mi Browser (Alt)" ;;
        "cn.wps.moffice_eng.xiaomi.lite") echo "Mi Doc Viewer (WPS)" ;;
        "com.miui.qr") echo "Xiaomi QR Scanner" ;;
        "com.miui.mediaviewer") echo "MIUI Media Viewer" ;;
        "com.miui.mediaeditor") echo "MIUI Gallery Editor" ;;
        "com.miui.personalassistant") echo "App Vault (Smart Assistant)" ;;
        "com.miui.appvault") echo "App Vault (Core)" ;;
        "com.miui.themestore") echo "Themes Store" ;;
        "com.android.thememanager") echo "Themes Store (Alt 1)" ;;
        "com.xiaomi.thememanager") echo "Themes Store (Alt 2)" ;;
        "com.miui.findmy") echo "Find Device (HyperOS)" ;;
        "com.xiaomi.finddevice") echo "Find Device (Legacy)" ;;
        "com.xiaomi.scanner") echo "AI Scanner (HyperOS)" ;;
        "com.miui.scanner") echo "Mi Scanner (Legacy)" ;;
        "com.xiaomi.market") echo "GetApps (Xiaomi Market)" ;;
        "com.xiaomi.mipicks") echo "GetApps (Alt)" ;;
        "com.miui.securitycenter") echo "Security Center" ;;
        "com.xiaomi.account") echo "Xiaomi Account Framework" ;;
        "com.miui.cloudservice") echo "Xiaomi Cloud Service" ;;
        "com.miui.micloudsync") echo "Xiaomi Cloud Sync" ;;
        "com.miui.cloudbackup") echo "Xiaomi Cloud Backup" ;;
        "com.xiaomi.roaming") echo "Mi Roaming" ;;
        "com.miui.roaming") echo "Mi Roaming (Alt)" ;;
        "com.miui.aod") echo "Always-on Display" ;;
        "com.xiaomi.hypercomm") echo "HyperOS Interconnect" ;;
        "com.miui.audiomonitor") echo "Audio Monitor Service" ;;
        "com.miui.voiceassistProxy") echo "Voice Assist Proxy" ;;
        "com.xiaomi.aiasst.service") echo "Xiaomi AI Assistant Service" ;;
        "com.xiaomi.aiasst.vision") echo "Xiaomi AI Vision" ;;
        "com.xiaomi.mibrain.speech") echo "Xiaomi AI Speech Engine" ;;
        "com.xiaomi.metoknlp") echo "Xiaomi Location Services" ;;
        "com.android.dreams.basic") echo "Basic Daydreams" ;;
        "com.android.dreams.phototable") echo "Photo Table" ;;
        "com.android.printspooler") echo "Android Print Spooler" ;;
        "com.android.bips") echo "Default Print Service" ;;
        "com.android.bookmarkprovider") echo "Bookmark Provider" ;;
        "com.android.traceur") echo "System Tracing" ;;
        "com.miui.contentextension") echo "MIUI Content Extension" ;;
        "com.miui.carlink") echo "MIUI CarLink" ;;
        "com.miui.thirdappassistant") echo "Third App Assistant" ;;
        "com.xiaomi.aicr") echo "Xiaomi AICR" ;;
        "com.miui.misightservice") echo "Mi Sight Service" ;;
        "com.xiaomi.barrage") echo "Xiaomi Barrage" ;;
        "com.xiaomi.mirror") echo "Xiaomi Mirror" ;;
        "com.miui.voiceassistoverlay") echo "Voice Assist Overlay" ;;
        *) echo "$pkg" ;;
    esac
}

# Function to cache device state
cache_device_state() {
    echo -e "${GRAY}[System] Syncing ADB package state to local cache...${RESET}"
    adb -s "$TARGET_ID" shell pm list packages -u > "$TEMP_DIR/adb_all.txt" 2>/dev/null || true
    adb -s "$TARGET_ID" shell pm list packages -e > "$TEMP_DIR/adb_active.txt" 2>/dev/null || true
    adb -s "$TARGET_ID" shell pm list packages -d > "$TEMP_DIR/adb_disabled.txt" 2>/dev/null || true
}

# Function to check app state
check_app_state() {
    local pkg="$1"
    APP_STATE="Not Installed / Removed"
    APP_STATE_COLOR="$GRAY"
    
    if grep -qi "package:$pkg" "$TEMP_DIR/adb_all.txt" 2>/dev/null; then
        APP_STATE="Uninstalled (User 0)"
        APP_STATE_COLOR="$YELLOW"
        
        if grep -qi "package:$pkg" "$TEMP_DIR/adb_active.txt" 2>/dev/null; then
            APP_STATE="Installed (Active)"
            APP_STATE_COLOR="$GREEN"
        fi
        
        if grep -qi "package:$pkg" "$TEMP_DIR/adb_disabled.txt" 2>/dev/null; then
            APP_STATE="Frozen (Disabled)"
            APP_STATE_COLOR="$CYAN"
        fi
    fi
}

# Function to execute action
execute_action() {
    local pkg="$1"
    local lbl="$2"
    
    check_app_state "$pkg"
    
    if [[ "$SKIP_NOT_INSTALLED" == "1" ]]; then
        local should_skip=0
        local skip_reason=""
        
        if [[ "$MODE_NAME" == "RESTORE" ]]; then
            if [[ "$APP_STATE" == "Installed (Active)" ]]; then
                should_skip=1
                skip_reason="App is already Installed and Active"
            fi
        else
            if [[ "$APP_STATE" == "Not Installed / Removed" ]]; then
                should_skip=1
                skip_reason="Not Installed"
            elif [[ "$APP_STATE" == "Uninstalled (User 0)" ]]; then
                should_skip=1
                skip_reason="Already Safely Removed"
            elif [[ "$APP_STATE" == "Frozen (Disabled)" ]]; then
                should_skip=1
                skip_reason="Already Frozen"
            fi
        fi
        
        if [[ "$should_skip" == "1" ]]; then
            echo -e "${GRAY}----------------------------------------------------${RESET}"
            echo -e "Processing: ${WHITE}$lbl${RESET} ($pkg)"
            echo -e "App Status: ${APP_STATE_COLOR}$APP_STATE${RESET}"
            echo -e "${YELLOW}[!] Skipped automatically ($skip_reason).${RESET}"
            echo ""
            return
        fi
    fi
    
    echo -e "${GRAY}----------------------------------------------------${RESET}"
    echo -e "Processing: ${WHITE}$lbl${RESET} ($pkg)"
    echo -e "App Status: ${APP_STATE_COLOR}$APP_STATE${RESET}"
    
    if [[ "$MODE_NAME" == "RESTORE" ]]; then
        echo "Executing Action: RESTORE..."
        adb -s "$TARGET_ID" shell cmd package install-existing "$pkg" >/dev/null 2>&1 || true
        adb -s "$TARGET_ID" shell pm enable "$pkg" >/dev/null 2>&1 || true
    else
        echo "Executing Action: $CMD_ACTION..."
        adb -s "$TARGET_ID" shell $CMD_ACTION "$pkg" >/dev/null 2>&1 || true
    fi
    
    echo -e "${GREEN}[OK] Command Sent.${RESET}"
    echo "$(date) | $MODE_VERB | $pkg | $lbl" >> "$LOGFILE"
    echo ""
}

# Function to process phase
process_phase() {
    local apps="$1"
    local phase_name="$2"
    local auto_mode="$3"
    
    for pkg in $apps; do
        local lbl=$(get_app_name "$pkg")
        execute_action "$pkg" "$lbl"
    done
}

# Main menu
main_menu() {
    while true; do
        clear
        echo ""
        echo -e "${GRAY}====================================================================================================================${RESET}"
        echo -e "${BOLD}${WHITE}  MAIN MENU ${CYAN}-${WHITE} Select Functionality${RESET}"
        echo -e "${GRAY}====================================================================================================================${RESET}"
        echo ""
        echo -e "${GREEN}[1] Standard Debloat (Phases 1-4)${RESET}"
        echo "    Automated or guided debloating using the built-in database of 130+ known packages."
        echo ""
        echo -e "${CYAN}[2] Quick Debloat - Phase 1 Only (Safe Apps)${RESET}"
        echo "    Automatically remove all ads, analytics, and junk services."
        echo ""
        echo -e "${YELLOW}[3] Restore Mode${RESET}"
        echo "    Re-enables frozen apps or reinstalls safely removed apps."
        echo ""
        echo -e "${RED}[E] Exit Commander${RESET}"
        echo ""
        echo -e "${GRAY}----------------------------------------------------${RESET}"
        echo -n "Press [1], [2], [3], or [E]xit: "
        
        read -n 1 choice
        echo ""
        
        case $choice in
            1) standard_debloat ;;
            2) quick_debloat ;;
            3) restore_mode ;;
            e|E) echo "Goodbye!"; exit 0 ;;
            *) echo "Invalid choice" ;;
        esac
    done
}

# Standard debloat
standard_debloat() {
    MODE_NAME="SAFE_REMOVE"
    MODE_VERB="Safe Remove"
    CMD_ACTION="pm uninstall -k --user 0"
    
    clear
    echo ""
    echo -e "${GRAY}====================================================================================================================${RESET}"
    echo -e "${BOLD}${WHITE}  PREFERENCES${RESET}"
    echo -e "${GRAY}====================================================================================================================${RESET}"
    echo ""
    echo -e "${CYAN}Smart Filtering (Context-Aware Auto-Skip)${RESET}"
    echo "Automatically skips apps that are already uninstalled or frozen."
    echo ""
    echo -n "Enable Smart Filtering? [Y/n]: "
    read -n 1 filter_choice
    echo ""
    
    if [[ "$filter_choice" != "n" && "$filter_choice" != "N" ]]; then
        SKIP_NOT_INSTALLED=1
        echo -e "${GREEN}Smart Filtering Enabled.${RESET}"
    else
        SKIP_NOT_INSTALLED=0
        echo -e "${RED}Smart Filtering Disabled.${RESET}"
    fi
    
    # Process each phase
    for phase in 1 2 3 4; do
        local apps=""
        local phase_name=""
        local bg_color=""
        
        case $phase in
            1) apps="$apps_p1"; phase_name="Ads, Analytics & Junk Services"; bg_color="$BG_GREEN" ;;
            2) apps="$apps_p2"; phase_name="User Tools & Features"; bg_color="$BG_YELLOW" ;;
            3) apps="$apps_p3"; phase_name="Risky System Apps"; bg_color="$BG_RED" ;;
            4) apps="$apps_p4"; phase_name="Hidden System Apps"; bg_color="$BG_MAGENTA" ;;
        esac
        
        clear
        echo ""
        echo -e "${GRAY}====================================================================================================================${RESET}"
        echo -e "${BOLD}${WHITE}  PHASE $phase/4 | $phase_name${RESET}"
        echo -e "${GRAY}====================================================================================================================${RESET}"
        echo ""
        echo -e "${bg_color}  SELECT MODE  ${RESET}"
        echo ""
        echo -e "[A]uto Process All Apps"
        echo -e "[S]kip Phase #$phase"
        echo ""
        echo -n "Press [A] or [S]: "
        
        read -n 1 phase_choice
        echo ""
        
        if [[ "$phase_choice" == "s" || "$phase_choice" == "S" ]]; then
            echo "Skipping Phase $phase..."
            sleep 1
            continue
        fi
        
        echo ""
        echo "Processing Phase $phase..."
        echo ""
        
        process_phase "$apps" "$phase_name" "auto"
        
        echo ""
        echo "Phase $phase complete. Press any key to continue..."
        read -n 1
    done
    
    finish
}

# Quick debloat
quick_debloat() {
    MODE_NAME="SAFE_REMOVE"
    MODE_VERB="Safe Remove"
    CMD_ACTION="pm uninstall -k --user 0"
    SKIP_NOT_INSTALLED=1
    
    clear
    echo ""
    echo -e "${BG_GREEN}  QUICK DEBLOAT - Processing Safe Apps (Phase 1)  ${RESET}"
    echo ""
    
    process_phase "$apps_p1" "Safe Apps" "auto"
    
    finish
}

# Restore mode
restore_mode() {
    MODE_NAME="RESTORE"
    MODE_VERB="Restore"
    CMD_ACTION=""
    SKIP_NOT_INSTALLED=1
    
    local all_apps="$apps_p1 $apps_p2 $apps_p3 $apps_p4 $apps_restore_only"
    
    clear
    echo ""
    echo -e "${BG_CYAN}  RESTORE MODE - Restoring All Apps  ${RESET}"
    echo ""
    
    process_phase "$all_apps" "All Apps" "auto"
    
    finish
}

# Finish
finish() {
    cache_device_state
    
    clear
    echo ""
    echo -e "${GRAY}====================================================================================================================${RESET}"
    echo -e "${BOLD}${WHITE}  SUMMARY - Complete${RESET}"
    echo -e "${GRAY}====================================================================================================================${RESET}"
    echo ""
    echo -e "${BG_CYAN}  TASK COMPLETED  ${RESET}"
    echo ""
    echo -e "${GREEN}[v]${RESET} Log saved to: ${WHITE}$LOGFILE${RESET}"
    echo ""
    echo "To restore an app manually via ADB use:"
    echo "  adb shell cmd package install-existing <package_name>"
    echo ""
    echo "Press any key to return to Main Menu..."
    read -n 1
}

# Check devices
check_devices() {
    clear
    echo ""
    echo -e "${GRAY}====================================================================================================================${RESET}"
    echo -e "${BOLD}${WHITE}  HYPEROS DEBLOAT COMMANDER ${CYAN}-${WHITE} v17.1 macOS/Linux ${CYAN}-${WHITE} System Ready${RESET}"
    echo -e "${GRAY}====================================================================================================================${RESET}"
    echo ""
    echo -e "${CYAN}  [+]${WHITE} Target OS:       Xiaomi HyperOS / MIUI (Android 13/14+)${RESET}"
    echo -e "${CYAN}  [+]${WHITE} Database:        130+ Bloatware Packages Loaded (4 Phases)${RESET}"
    echo ""
    echo -e "${BG_CYAN}  STATUS: WAITING FOR DEVICE...  ${RESET}"
    
    adb start-server >/dev/null 2>&1
    
    echo ""
    echo -e "${GRAY}  Scanning USB ports...${RESET}"
    
    # Get connected devices
    local devices=$(adb devices -l 2>/dev/null | grep -v "List of devices" | grep -v "^$" | awk '{print $1}')
    local count=$(echo "$devices" | grep -c . || echo "0")
    
    if [[ "$count" == "0" || -z "$devices" ]]; then
        echo ""
        echo -e "${BG_RED}  ERROR: CONNECTION FAILED  ${RESET}"
        echo -e "${RED}  [!]${RESET} No device detected via ADB. Check USB Debugging and Cable."
        echo ""
        echo "Press any key to retry..."
        read -n 1
        check_devices
        return
    fi
    
    # Get first device
    TARGET_ID=$(echo "$devices" | head -n 1)
    TARGET_MODEL=$(adb -s "$TARGET_ID" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
    
    echo ""
    echo -e "${BG_GREEN}  DEVICE CONNECTED  ${RESET}"
    echo -e "${GREEN}  [v]${RESET} Model: ${WHITE}$TARGET_MODEL${RESET}"
    echo -e "${GREEN}  [v]${RESET} ID:    ${WHITE}$TARGET_ID${RESET}"
    
    # Setup log file
    LOGFILE="Debloat_Log_$(date +%Y-%m-%d_%H-%M-%S).txt"
    echo "[LOG STARTED]" > "$LOGFILE"
    echo "Target OS: Xiaomi HyperOS" >> "$LOGFILE"
    echo "Date: $(date)" >> "$LOGFILE"
    echo "Device Model: $TARGET_MODEL" >> "$LOGFILE"
    echo "Device ID: $TARGET_ID" >> "$LOGFILE"
    echo "--------------------------------------------------------" >> "$LOGFILE"
    
    sleep 2
    cache_device_state
}

# Main
echo ""
echo "Xiaomi HyperOS Debloat Commander v17.1"
echo "macOS/Linux Version"
echo ""

# Check if ADB is installed
if ! command -v adb &> /dev/null; then
    echo -e "${RED}Error: ADB is not installed or not in PATH${RESET}"
    echo ""
    echo "Please install ADB first:"
    echo "  macOS:   brew install android-platform-tools"
    echo "  Linux:   sudo apt install android-tools-adb"
    echo ""
    exit 1
fi

check_devices
main_menu
