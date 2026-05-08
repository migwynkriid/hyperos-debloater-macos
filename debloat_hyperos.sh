#!/bin/bash
# Xiaomi HyperOS Debloat Commander v17.1 (macOS Port)
# A powerful, interactive, and completely reversible utility to safely remove bloatware from Xiaomi devices.

set -e

# Change to script directory
cd "$(dirname "$0")"

# ADB command - check if in current folder, otherwise use PATH
if [[ -f "./adb" ]]; then
    ADB_CMD="./adb"
elif command -v adb &> /dev/null; then
    ADB_CMD="adb"
else
    echo "ERROR: ADB not found. Please install ADB or place it in this folder."
    echo "Install via Homebrew: brew install android-platform-tools"
    exit 1
fi

# ===============================================================================================
#  CONFIGURATION & APP DEFINITIONS
# ===============================================================================================

# 1. PHASE 1: SAFE LIST (Ads, Analytics, Background Stubs, Junk Services)
apps_p1="com.miui.analytics com.miui.systemAdSolution com.miui.msa.global com.miui.daemon com.facebook.appmanager com.facebook.services com.facebook.system com.facebook.katana com.miui.cleanmaster com.miui.miservice com.miui.touchassistant com.miui.hybrid com.miui.hybrid.accessory com.xiaomi.discover com.xiaomi.ab com.miui.cit com.miui.wmsvc com.miui.userguide com.miui.backup com.xiaomi.xmsf com.mi.global.bbs com.mi.global.shop com.miui.nextpay com.miui.tsmclient com.miui.greenguard com.xiaomi.gamecenter com.xiaomi.gamecenter.sdk.service com.miui.uireporter com.miui.securityadd com.baidu.input_mi com.iflytek.inputmethod.miui com.sohu.inputmethod.sogou.xiaomi com.tencent.soter.soterserver com.bsp.catchlog com.xiaomi.security.onetrack com.wapi.wapicertmanage com.miui.newmidrive com.xiaomi.aireco com.qti.qualcomm.deviceinfo com.unionpay.tsmservice.mi com.miui.guardprovider com.miui.powerinsight com.miui.yellowpage com.xiaomi.pass com.mipay.wallet"

# 2. PHASE 2: ADVANCED LIST (User-Facing Apps)
apps_p2="com.miui.compass com.miui.weather2 com.miui.notes com.miui.calculator com.miui.videoplayer com.miui.player com.xiaomi.glgm com.miui.gallery com.xiaomi.midrop com.miui.fmservice com.miui.fm com.android.stk com.xiaomi.payment com.xiaomi.vipaccount com.duokan.phone.remotecontroller com.xiaomi.smarthome com.android.calendar com.miui.calendar com.android.deskclock com.android.providers.downloads.ui com.android.fileexplorer com.mi.android.globalFileexplorer com.android.soundrecorder com.android.email com.miui.screenrecorder com.miui.huanji com.android.browser com.miui.browser cn.wps.moffice_eng.xiaomi.lite com.miui.qr com.miui.mediaviewer com.miui.mediaeditor"

# 3. PHASE 3: RISKY SYSTEM APPS
apps_p3="com.miui.personalassistant com.miui.appvault com.miui.themestore com.android.thememanager com.xiaomi.thememanager com.miui.findmy com.xiaomi.finddevice com.xiaomi.scanner com.miui.scanner com.xiaomi.market com.xiaomi.mipicks com.miui.securitycenter com.xiaomi.account com.miui.cloudservice com.miui.micloudsync com.miui.cloudbackup com.xiaomi.roaming com.miui.roaming"

# 4. PHASE 4: HIDDEN SYSTEM APPS (Canta Suggestions & HyperOS Background)
apps_p4="com.miui.aod com.xiaomi.hypercomm com.miui.audiomonitor com.miui.voiceassistProxy com.xiaomi.aiasst.service com.xiaomi.aiasst.vision com.xiaomi.mibrain.speech com.xiaomi.metoknlp com.android.dreams.basic com.android.dreams.phototable com.android.printspooler com.android.bips com.android.bookmarkprovider com.android.traceur com.miui.contentextension com.miui.carlink com.miui.thirdappassistant com.xiaomi.aicr com.miui.misightservice com.xiaomi.barrage com.xiaomi.mirror com.miui.voiceassistoverlay"

# 5. RESTORE ONLY LIST
apps_restore_only="com.miui.extraphoto com.miui.face com.android.egg com.miui.freeform com.miui.mishare.connectivity com.miui.phrase com.miui.vsimcore com.miui.virtualsim"

# ===============================================================================================
#  ANSI COLORS
# ===============================================================================================
RESET="\033[0m"
BOLD="\033[1m"

# Background colors with black text
BG_CYAN="\033[46m\033[30m"
BG_MAG="\033[45m\033[30m"
BG_GRN="\033[42m\033[30m"
BG_YEL="\033[43m\033[30m"
BG_RED="\033[41m\033[97m"

# Text colors
TXT_CYAN="\033[96m"
TXT_GRN="\033[92m"
TXT_YEL="\033[93m"
TXT_RED="\033[91m"
TXT_MAG="\033[95m"
TXT_GRAY="\033[90m"
TXT_WHT="\033[97m"

# ===============================================================================================
#  TEMP FILES & LOG
# ===============================================================================================
TEMP_DIR="${TMPDIR:-/tmp}"
ADB_ALL_FILE="$TEMP_DIR/adb_all.txt"
ADB_ACTIVE_FILE="$TEMP_DIR/adb_active.txt"
ADB_DISABLED_FILE="$TEMP_DIR/adb_disabled.txt"
MATCHED_APPS_FILE="$TEMP_DIR/matched_apps.txt"

# Log file with safe date/time
SAFE_DT=$(date "+%Y-%m-%d_%H-%M-%S")
LOGFILE="Debloat_Log_${SAFE_DT}.txt"

echo "[LOG STARTED]" > "$LOGFILE"
echo "Target OS: Xiaomi HyperOS" >> "$LOGFILE"
echo "Date: $(date)" >> "$LOGFILE"
echo "--------------------------------------------------------" >> "$LOGFILE"

# ===============================================================================================
#  UTILITY FUNCTIONS
# ===============================================================================================

print_line() {
    printf "${TXT_GRAY}====================================================================================================================${RESET}\n"
}

print_separator() {
    printf "${TXT_GRAY}--------------------------------------------------------------------------------------------------------------------${RESET}\n"
}

clear_screen() {
    clear
}

wait_key() {
    read -n 1 -s -r -p ""
}

# Get friendly app name from package
get_app_name() {
    local pkg="$1"
    APP_LABEL="$pkg"
    
    # PHASE 1: SAFE
    case "$pkg" in
        "com.miui.analytics") APP_LABEL="MIUI Analytics (Ad Tracking)" ;;
        "com.miui.systemAdSolution") APP_LABEL="MIUI System Ad Solution" ;;
        "com.miui.msa.global") APP_LABEL="MSA (Main System Ads Service)" ;;
        "com.miui.daemon") APP_LABEL="MIUI Daemon (Data Collection)" ;;
        "com.xiaomi.discover") APP_LABEL="Xiaomi Discover (Ads/Recommendations)" ;;
        "com.xiaomi.ab") APP_LABEL="Xiaomi AB (Ads)" ;;
        "com.facebook.appmanager") APP_LABEL="Facebook App Manager" ;;
        "com.facebook.services") APP_LABEL="Facebook Services" ;;
        "com.facebook.system") APP_LABEL="Facebook System Framework" ;;
        "com.facebook.katana") APP_LABEL="Facebook App (Pre-installed)" ;;
        "com.mi.global.bbs") APP_LABEL="Xiaomi Community" ;;
        "com.miui.cloudservice.sysbase") APP_LABEL="Xiaomi Cloud Service Base" ;;
        "com.miui.cleanmaster") APP_LABEL="Clean Master (Ads/Junk Cleaner)" ;;
        "com.miui.miservice") APP_LABEL="Mi Services (Support/Ads)" ;;
        "com.miui.touchassistant") APP_LABEL="Quick Ball (Touch Assistant)" ;;
        "com.miui.hybrid") APP_LABEL="Quick Apps Service" ;;
        "com.miui.hybrid.accessory") APP_LABEL="Quick Apps Accessory" ;;
        "com.miui.cit") APP_LABEL="CIT (Hardware Test)" ;;
        "com.miui.wmsvc") APP_LABEL="WM Service (Cloud Backups)" ;;
        "com.miui.userguide") APP_LABEL="User Guide" ;;
        "com.miui.backup") APP_LABEL="MIUI Backup" ;;
        "com.xiaomi.xmsf") APP_LABEL="Xiaomi Service Framework" ;;
        "com.mi.global.shop") APP_LABEL="Xiaomi Store" ;;
        "com.miui.nextpay") APP_LABEL="Mi Pay Framework" ;;
        "com.miui.tsmclient") APP_LABEL="Mi Pay Client" ;;
        "com.miui.greenguard") APP_LABEL="Family Link / Kids Mode" ;;
        "com.xiaomi.gamecenter") APP_LABEL="Xiaomi Game Center" ;;
        "com.xiaomi.gamecenter.sdk.service") APP_LABEL="Xiaomi Game SDK" ;;
        "com.miui.uireporter") APP_LABEL="MIUI UI Analytics" ;;
        "com.miui.securityadd") APP_LABEL="MIUI Security Addons" ;;
        "com.baidu.input_mi") APP_LABEL="Baidu Keyboard (Chinese)" ;;
        "com.iflytek.inputmethod.miui") APP_LABEL="iFlyTek Keyboard" ;;
        "com.sohu.inputmethod.sogou.xiaomi") APP_LABEL="Sogou Keyboard" ;;
        "com.tencent.soter.soterserver") APP_LABEL="Tencent Soter Framework" ;;
        "com.bsp.catchlog") APP_LABEL="BSP Catch Log" ;;
        "com.xiaomi.security.onetrack") APP_LABEL="Xiaomi OneTrack (Telemetry)" ;;
        "com.wapi.wapicertmanage") APP_LABEL="WAPI Certificate Manage" ;;
        "com.miui.newmidrive") APP_LABEL="Xiaomi Cloud Drive" ;;
        "com.xiaomi.aireco") APP_LABEL="Xiaomi AI Recommendations" ;;
        "com.qti.qualcomm.deviceinfo") APP_LABEL="Qualcomm Device Info" ;;
        "com.unionpay.tsmservice.mi") APP_LABEL="UnionPay TSM Service" ;;
        "com.miui.guardprovider") APP_LABEL="MIUI Guard Provider" ;;
        "com.miui.powerinsight") APP_LABEL="MIUI Power Insight" ;;
        "com.miui.yellowpage") APP_LABEL="MIUI Yellow Pages" ;;
        "com.xiaomi.pass") APP_LABEL="Xiaomi Pass" ;;
        "com.mipay.wallet") APP_LABEL="Xiaomi Wallet" ;;
        # PHASE 2: ADVANCED
        "com.miui.compass") APP_LABEL="Mi Compass" ;;
        "com.miui.weather2") APP_LABEL="Mi Weather" ;;
        "com.miui.notes") APP_LABEL="Mi Notes" ;;
        "com.miui.calculator") APP_LABEL="Mi Calculator" ;;
        "com.miui.videoplayer") APP_LABEL="Mi Video" ;;
        "com.miui.player") APP_LABEL="Mi Music" ;;
        "com.xiaomi.glgm") APP_LABEL="Xiaomi Games" ;;
        "com.miui.gallery") APP_LABEL="Mi Gallery" ;;
        "com.miui.fmservice") APP_LABEL="FM Radio Service" ;;
        "com.miui.fm") APP_LABEL="FM Radio App" ;;
        "com.android.stk") APP_LABEL="SIM Toolkit" ;;
        "com.xiaomi.midrop") APP_LABEL="Mi Drop (Share)" ;;
        "com.xiaomi.payment") APP_LABEL="Mi Pay / Wallet" ;;
        "com.xiaomi.vipaccount") APP_LABEL="Xiaomi VIP Account" ;;
        "com.duokan.phone.remotecontroller") APP_LABEL="Mi Remote" ;;
        "com.xiaomi.smarthome") APP_LABEL="Xiaomi Home" ;;
        "com.android.calendar") APP_LABEL="Xiaomi Calendar" ;;
        "com.miui.calendar") APP_LABEL="Xiaomi Calendar (Alt)" ;;
        "com.android.deskclock") APP_LABEL="Xiaomi Clock" ;;
        "com.android.providers.downloads.ui") APP_LABEL="Downloads App" ;;
        "com.mi.android.globalFileexplorer") APP_LABEL="File Manager" ;;
        "com.android.fileexplorer") APP_LABEL="File Manager (Alt)" ;;
        "com.android.soundrecorder") APP_LABEL="Sound Recorder" ;;
        "com.android.email") APP_LABEL="Xiaomi Email App" ;;
        "com.miui.screenrecorder") APP_LABEL="Screen Recorder" ;;
        "com.miui.huanji") APP_LABEL="Mi Mover" ;;
        "com.android.browser") APP_LABEL="Mi Browser" ;;
        "com.miui.browser") APP_LABEL="Mi Browser (Alt)" ;;
        "cn.wps.moffice_eng.xiaomi.lite") APP_LABEL="Mi Doc Viewer (WPS)" ;;
        "com.miui.qr") APP_LABEL="Xiaomi QR Scanner" ;;
        "com.miui.mediaviewer") APP_LABEL="MIUI Media Viewer" ;;
        "com.miui.mediaeditor") APP_LABEL="MIUI Gallery Editor" ;;
        # PHASE 3: RISKY
        "com.miui.personalassistant") APP_LABEL="App Vault (Smart Assistant)" ;;
        "com.miui.appvault") APP_LABEL="App Vault (Core)" ;;
        "com.miui.themestore") APP_LABEL="Themes Store" ;;
        "com.android.thememanager") APP_LABEL="Themes Store (Alt 1)" ;;
        "com.xiaomi.thememanager") APP_LABEL="Themes Store (Alt 2)" ;;
        "com.miui.findmy") APP_LABEL="Find Device (HyperOS)" ;;
        "com.xiaomi.finddevice") APP_LABEL="Find Device (Legacy)" ;;
        "com.xiaomi.scanner") APP_LABEL="AI Scanner (HyperOS)" ;;
        "com.miui.scanner") APP_LABEL="Mi Scanner (Legacy)" ;;
        "com.xiaomi.market") APP_LABEL="GetApps (Xiaomi Market)" ;;
        "com.xiaomi.mipicks") APP_LABEL="GetApps (Alt)" ;;
        "com.miui.securitycenter") APP_LABEL="Security Center" ;;
        "com.xiaomi.account") APP_LABEL="Xiaomi Account Framework" ;;
        "com.miui.cloudservice") APP_LABEL="Xiaomi Cloud Service" ;;
        "com.miui.micloudsync") APP_LABEL="Xiaomi Cloud Sync" ;;
        "com.miui.cloudbackup") APP_LABEL="Xiaomi Cloud Backup" ;;
        "com.xiaomi.roaming") APP_LABEL="Mi Roaming" ;;
        "com.miui.roaming") APP_LABEL="Mi Roaming (Alt)" ;;
        # PHASE 4: HIDDEN
        "com.miui.aod") APP_LABEL="Always-on Display" ;;
        "com.xiaomi.hypercomm") APP_LABEL="HyperOS Interconnect" ;;
        "com.miui.audiomonitor") APP_LABEL="Audio Monitor Service" ;;
        "com.miui.voiceassistProxy") APP_LABEL="Voice Assist Proxy" ;;
        "com.xiaomi.aiasst.service") APP_LABEL="Xiaomi AI Assistant Service" ;;
        "com.xiaomi.aiasst.vision") APP_LABEL="Xiaomi AI Vision" ;;
        "com.xiaomi.mibrain.speech") APP_LABEL="Xiaomi AI Speech Engine" ;;
        "com.xiaomi.metoknlp") APP_LABEL="Xiaomi Location Services" ;;
        "com.android.dreams.basic") APP_LABEL="Basic Daydreams" ;;
        "com.android.dreams.phototable") APP_LABEL="Photo Table" ;;
        "com.android.printspooler") APP_LABEL="Android Print Spooler" ;;
        "com.android.bips") APP_LABEL="Default Print Service" ;;
        "com.android.bookmarkprovider") APP_LABEL="Bookmark Provider" ;;
        "com.android.traceur") APP_LABEL="System Tracing" ;;
        "com.miui.contentextension") APP_LABEL="MIUI Content Extension" ;;
        "com.miui.carlink") APP_LABEL="MIUI CarLink" ;;
        "com.miui.thirdappassistant") APP_LABEL="Third App Assistant" ;;
        "com.xiaomi.aicr") APP_LABEL="Xiaomi AICR" ;;
        "com.miui.misightservice") APP_LABEL="Mi Sight Service" ;;
        "com.xiaomi.barrage") APP_LABEL="Xiaomi Barrage" ;;
        "com.xiaomi.mirror") APP_LABEL="Xiaomi Mirror" ;;
        "com.miui.voiceassistoverlay") APP_LABEL="Voice Assist Overlay" ;;
        # RESTORE ONLY
        "com.miui.extraphoto") APP_LABEL="Extra Photo Features" ;;
        "com.miui.face") APP_LABEL="Face Detection" ;;
        "com.android.egg") APP_LABEL="Android Easter Egg" ;;
        "com.miui.freeform") APP_LABEL="Freeform Windows" ;;
        "com.miui.mishare.connectivity") APP_LABEL="Mi Share Connectivity" ;;
        "com.miui.phrase") APP_LABEL="Phrase Service" ;;
        "com.miui.vsimcore") APP_LABEL="Virtual SIM Core" ;;
        "com.miui.virtualsim") APP_LABEL="Virtual SIM" ;;
    esac
}

# Check app state from cache
check_app_state() {
    local pkg="$1"
    APP_STATE="Not Installed / Removed"
    APP_STATE_COLOR="$TXT_GRAY"
    
    if grep -qi "package:$pkg$" "$ADB_ALL_FILE" 2>/dev/null; then
        APP_STATE="Uninstalled (User 0)"
        APP_STATE_COLOR="$TXT_YEL"
        
        if grep -qi "package:$pkg$" "$ADB_ACTIVE_FILE" 2>/dev/null; then
            APP_STATE="Installed (Active)"
            APP_STATE_COLOR="$TXT_GRN"
        fi
        
        if grep -qi "package:$pkg$" "$ADB_DISABLED_FILE" 2>/dev/null; then
            APP_STATE="Frozen (Disabled)"
            APP_STATE_COLOR="$TXT_CYAN"
        fi
    fi
}

# Cache device state
cache_device_state() {
    printf "  ${TXT_GRAY}[System] Syncing ADB package state to high-speed local cache...${RESET}\n"
    $ADB_CMD -s "$TARGET_ID" shell pm list packages -u > "$ADB_ALL_FILE" 2>/dev/null || true
    $ADB_CMD -s "$TARGET_ID" shell pm list packages -e > "$ADB_ACTIVE_FILE" 2>/dev/null || true
    $ADB_CMD -s "$TARGET_ID" shell pm list packages -d > "$ADB_DISABLED_FILE" 2>/dev/null || true
}

# Execute action on app
execute_action() {
    local pkg="$1"
    local lbl="$2"
    local type="$3"
    
    case "$type" in
        "SAFE") THEME_BG="$BG_GRN" ;;
        "CAUTION") THEME_BG="$BG_YEL" ;;
        "DANGER") THEME_BG="$BG_RED" ;;
        "HIDDEN") THEME_BG="$BG_MAG" ;;
        *) THEME_BG="$BG_CYAN" ;;
    esac
    
    check_app_state "$pkg"
    
    if [[ "$SKIP_NOT_INSTALLED" == "1" ]]; then
        local SHOULD_SKIP=0
        local SKIP_REASON=""
        
        if [[ "$MODE_NAME" == "RESTORE" ]]; then
            if [[ "$APP_STATE" == "Installed (Active)" ]]; then
                SHOULD_SKIP=1
                SKIP_REASON="App is already Installed and Active"
            fi
        else
            case "$APP_STATE" in
                "Not Installed / Removed")
                    SHOULD_SKIP=1
                    SKIP_REASON="Not Installed"
                    ;;
                "Uninstalled (User 0)")
                    SHOULD_SKIP=1
                    SKIP_REASON="Already Safely Removed"
                    ;;
                "Frozen (Disabled)")
                    SHOULD_SKIP=1
                    SKIP_REASON="Already Frozen"
                    ;;
            esac
        fi
        
        if [[ "$SHOULD_SKIP" == "1" ]]; then
            print_separator
            printf "  Processing: ${TXT_WHT}%s${RESET} (%s)\n" "$lbl" "$pkg"
            printf "  App Status: ${APP_STATE_COLOR}%s${RESET}\n" "$APP_STATE"
            printf "  ${TXT_YEL}[!] Skipped automatically (%s).${RESET}\n\n" "$SKIP_REASON"
            return
        fi
    fi
    
    print_separator
    printf "  Processing: ${TXT_WHT}%s${RESET} (%s)\n" "$lbl" "$pkg"
    printf "  App Status: ${APP_STATE_COLOR}%s${RESET}\n" "$APP_STATE"
    
    if [[ "$MODE_NAME" == "RESTORE" ]]; then
        printf "  Executing Action: RESTORE...\n"
        $ADB_CMD -s "$TARGET_ID" shell cmd package install-existing "$pkg" >/dev/null 2>&1 || true
        $ADB_CMD -s "$TARGET_ID" shell pm enable "$pkg" >/dev/null 2>&1 || true
    else
        printf "  Executing Action: %s...\n" "$CMD_ACTION"
        $ADB_CMD -s "$TARGET_ID" shell $CMD_ACTION "$pkg" >/dev/null 2>&1 || true
    fi
    
    printf "  ${TXT_GRN}[OK] Command Sent.${RESET}\n"
    echo "$(date '+%H:%M:%S') | $MODE_VERB | $pkg | $lbl" >> "$LOGFILE"
    echo "" 
}

# Ask user for action
ask_user() {
    local pkg="$1"
    local lbl="$2"
    local type="$3"
    
    case "$type" in
        "SAFE") THEME_BG="$BG_GRN" ;;
        "CAUTION") THEME_BG="$BG_YEL" ;;
        "DANGER") THEME_BG="$BG_RED" ;;
        "HIDDEN") THEME_BG="$BG_MAG" ;;
        *) THEME_BG="$BG_CYAN" ;;
    esac
    
    check_app_state "$pkg"
    
    if [[ "$SKIP_NOT_INSTALLED" == "1" ]]; then
        local SHOULD_SKIP=0
        local SKIP_REASON=""
        
        if [[ "$MODE_NAME" == "RESTORE" ]]; then
            if [[ "$APP_STATE" == "Installed (Active)" ]]; then
                SHOULD_SKIP=1
                SKIP_REASON="App is already Installed and Active"
            fi
        else
            case "$APP_STATE" in
                "Not Installed / Removed")
                    SHOULD_SKIP=1
                    SKIP_REASON="Not Installed"
                    ;;
                "Uninstalled (User 0)")
                    SHOULD_SKIP=1
                    SKIP_REASON="Already Safely Removed"
                    ;;
                "Frozen (Disabled)")
                    SHOULD_SKIP=1
                    SKIP_REASON="Already Frozen"
                    ;;
            esac
        fi
        
        if [[ "$SHOULD_SKIP" == "1" ]]; then
            clear_screen
            print_manual_header
            printf "  ${BOLD}%s${RESET}\n" "$lbl"
            printf "  ${TXT_GRAY}%s${RESET}\n" "$pkg"
            printf "  App Status: ${APP_STATE_COLOR}%s${RESET}\n\n" "$APP_STATE"
            printf "  ${TXT_YEL}[!] Skipped automatically (%s).${RESET}\n" "$SKIP_REASON"
            sleep 1
            return
        fi
    fi
    
    clear_screen
    print_manual_header
    printf "  ${BOLD}%s${RESET}\n" "$lbl"
    printf "  ${TXT_GRAY}%s${RESET}\n" "$pkg"
    printf "  App Status: ${APP_STATE_COLOR}%s${RESET}\n\n" "$APP_STATE"
    
    local EXTRA_OPTIONS=""
    if [[ "$APP_STATE" == "Frozen (Disabled)" ]]; then
        EXTRA_OPTIONS="   ${TXT_YEL}[U]${RESET}nfreeze"
    fi
    
    printf "  >> %s?  ${TXT_GRN}[Y]${RESET}es - %s   ${TXT_RED}[N]${RESET}o - Skip%s   ${TXT_CYAN}[E]${RESET}xit Debloater\n" "$MODE_NAME" "$MODE_VERB" "$EXTRA_OPTIONS"
    
    while true; do
        read -n 1 -s choice
        case "${choice^^}" in
            Y)
                execute_action "$pkg" "$lbl" "MANUAL_CALL"
                break
                ;;
            N)
                printf "  ${TXT_RED} [--] Skipped.${RESET}\n"
                echo "$(date '+%H:%M:%S') | SKIPPED | $pkg | $lbl" >> "$LOGFILE"
                break
                ;;
            U)
                if [[ "$APP_STATE" == "Frozen (Disabled)" ]]; then
                    printf "\n  Processing: Unfreezing %s...\n" "$lbl"
                    $ADB_CMD -s "$TARGET_ID" shell pm enable "$pkg" >/dev/null 2>&1 || true
                    echo "$(date '+%H:%M:%S') | UNFREEZE | $pkg | $lbl" >> "$LOGFILE"
                fi
                break
                ;;
            E)
                finish_and_exit
                ;;
        esac
    done
}

print_manual_header() {
    print_line
    printf "  ${THEME_BG}  XIAOMI HYPEROS DEBLOATER | App Processing                                                                         ${RESET}\n"
    print_line
    echo ""
}

finish_and_exit() {
    clear_screen
    echo ""
    print_line
    printf "  ${BOLD}${TXT_WHT}  SUMMARY ${TXT_CYAN}-${TXT_WHT} Complete${RESET}\n"
    print_line
    echo ""
    printf "  ${BG_CYAN}  TASK COMPLETED                                                                                                     ${RESET}\n"
    echo ""
    printf "  ${TXT_GRN}  [v]${RESET} Log saved to: ${TXT_WHT}%s${RESET}\n" "$LOGFILE"
    echo ""
    printf "  ${TXT_GRAY}  To restore an app manually via ADB use:${RESET}\n"
    printf "  ${TXT_GRAY}  adb shell cmd package install-existing <package_name>${RESET}\n"
    echo ""
    printf "  Press any key to exit...\n"
    cache_device_state
    wait_key
    exit 0
}

# ===============================================================================================
#  STARTUP DASHBOARD
# ===============================================================================================

clear_screen
echo ""
print_line
printf "  ${BOLD}${TXT_WHT}  HYPEROS DEBLOAT COMMANDER ${TXT_CYAN}-${TXT_WHT} v17.1 Optimized (macOS) ${TXT_CYAN}-${TXT_WHT} System Ready${RESET}\n"
print_line
echo ""
printf "  ${TXT_CYAN}  [+]${TXT_WHT} Target OS:       Xiaomi HyperOS / MIUI (Android 13/14+)${RESET}\n"
printf "  ${TXT_CYAN}  [+]${TXT_WHT} Database:        130+ Bloatware Packages Loaded (4 Phases)${RESET}\n"
echo ""
printf "  ${BG_CYAN}  STATUS: WAITING FOR DEVICE...                                                                                      ${RESET}\n"
$ADB_CMD start-server >/dev/null 2>&1

# ===============================================================================================
#  STEP 1: DEVICE CONNECTION
# ===============================================================================================

check_devices() {
    echo ""
    printf "  ${TXT_GRAY}  Scanning USB ports...${RESET}\n"
    
    declare -a devices
    declare -a models
    local count=0
    
    while IFS= read -r line; do
        local device_id=$(echo "$line" | awk '{print $1}')
        if [[ -n "$device_id" && "$device_id" != "List" ]]; then
            count=$((count + 1))
            devices[$count]="$device_id"
            models[$count]=$($ADB_CMD -s "$device_id" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
        fi
    done < <($ADB_CMD devices -l 2>/dev/null | tail -n +2)
    
    if [[ $count -eq 0 ]]; then
        echo ""
        printf "  ${BG_RED}  ERROR: CONNECTION FAILED                                                                                          ${RESET}\n"
        printf "  ${TXT_RED}  [!]${RESET} No device detected via ADB. Check USB Debugging and Cable.\n"
        echo ""
        printf "  ${TXT_GRAY}  Press any key to retry...${RESET}\n"
        wait_key
        clear_screen
        check_devices
        return
    fi
    
    if [[ $count -eq 1 ]]; then
        TARGET_ID="${devices[1]}"
        TARGET_MODEL="${models[1]}"
        echo ""
        printf "  ${BG_GRN}  DEVICE CONNECTED                                                                                                  ${RESET}\n"
        printf "  ${TXT_GRN}  [v]${RESET} Model: ${TXT_WHT}%s${RESET}\n" "$TARGET_MODEL"
        printf "  ${TXT_GRN}  [v]${RESET} ID:    ${TXT_WHT}%s${RESET}\n" "$TARGET_ID"
        
        echo "Device Model: $TARGET_MODEL" >> "$LOGFILE"
        echo "Device ID: $TARGET_ID" >> "$LOGFILE"
        echo "--------------------------------------------------------" >> "$LOGFILE"
        
        sleep 1
        cache_device_state
        return
    fi
    
    # Multiple devices
    echo ""
    printf "  ${BG_YEL}  MULTIPLE DEVICES FOUND                                                                                            ${RESET}\n"
    for i in $(seq 1 $count); do
        printf "   ${TXT_WHT}[%d]${RESET} %s (%s)\n" "$i" "${models[$i]}" "${devices[$i]}"
    done
    echo ""
    printf "  >> Select Device (1-%d): " "$count"
    read -r selection
    
    TARGET_ID="${devices[$selection]}"
    TARGET_MODEL="${models[$selection]}"
    
    echo "Device Model: $TARGET_MODEL" >> "$LOGFILE"
    echo "Device ID: $TARGET_ID" >> "$LOGFILE"
    echo "--------------------------------------------------------" >> "$LOGFILE"
    
    echo ""
    printf "  ${TXT_GRN}  [+]${RESET} Selected: %s\n" "$TARGET_MODEL"
    sleep 1
    cache_device_state
}

check_devices

# ===============================================================================================
#  MAIN MENU
# ===============================================================================================

main_menu() {
    while true; do
        clear_screen
        echo ""
        print_line
        printf "  ${BOLD}${TXT_WHT}  MAIN MENU ${TXT_CYAN}-${TXT_WHT} Select Functionality${RESET}\n"
        print_line
        echo ""
        printf "  ${TXT_GRN}[1] Standard Debloat (Phases 1-4)${RESET}\n"
        printf "      Automated or guided debloating using the built-in database of 130+ known packages.\n"
        echo ""
        printf "  ${TXT_CYAN}[2] Interactive App Explorer (Filtered & Sorted)${RESET}\n"
        printf "      Browse ONLY the bloatware apps currently installed/frozen on your device via\n"
        printf "      an alphabetically sorted list, and manage them one by one.\n"
        echo ""
        printf "  ${TXT_YEL}[3] Refresh Device Cache${RESET}\n"
        printf "      Re-pulls the app states from the device if you've made manual changes outside the script.\n"
        echo ""
        printf "  ${TXT_RED}[E] Exit Commander${RESET}\n"
        echo ""
        print_separator
        printf "  Press ${TXT_GRN}[1]${RESET}, ${TXT_CYAN}[2]${RESET}, ${TXT_YEL}[3]${RESET}, or ${TXT_RED}[E]${RESET}xit...\n"
        
        read -n 1 -s choice
        case "${choice^^}" in
            1) mode_select ;;
            2) interactive_explorer ;;
            3) 
                cache_device_state
                ;;
            E) exit 0 ;;
        esac
    done
}

# ===============================================================================================
#  INTERACTIVE EXPLORER
# ===============================================================================================

interactive_explorer() {
    local SHOW_ACTIVE_ONLY=0
    local all_db_apps="$apps_p1 $apps_p2 $apps_p3 $apps_p4 $apps_restore_only"
    
    while true; do
        clear_screen
        echo ""
        print_line
        printf "  ${BG_CYAN}  INTERACTIVE APP EXPLORER                                                                                           ${RESET}\n"
        print_line
        echo ""
        printf "  ${TXT_GRAY}Filtering local cache against database... Please wait...${RESET}\n"
        
        rm -f "$MATCHED_APPS_FILE"
        
        for pkg in $all_db_apps; do
            local found=0
            if [[ "$SHOW_ACTIVE_ONLY" == "1" ]]; then
                if grep -qi "package:$pkg$" "$ADB_ACTIVE_FILE" 2>/dev/null; then
                    found=1
                fi
            else
                if grep -qi "package:$pkg$" "$ADB_ALL_FILE" 2>/dev/null; then
                    found=1
                fi
            fi
            
            if [[ $found -eq 1 ]]; then
                get_app_name "$pkg"
                echo "$APP_LABEL|$pkg" >> "$MATCHED_APPS_FILE"
            fi
        done
        
        declare -a app_list
        declare -a app_pkg
        local total_apps=0
        
        if [[ -f "$MATCHED_APPS_FILE" ]]; then
            while IFS='|' read -r label pkg; do
                total_apps=$((total_apps + 1))
                app_list[$total_apps]="$label ($pkg)"
                app_pkg[$total_apps]="$pkg"
            done < <(sort "$MATCHED_APPS_FILE")
            rm -f "$MATCHED_APPS_FILE"
        fi
        
        if [[ $total_apps -eq 0 ]]; then
            echo ""
            printf "  ${TXT_RED}[!] No apps found for the current filter.${RESET}\n"
            printf "  Press any key to continue..."
            wait_key
            if [[ "$SHOW_ACTIVE_ONLY" == "1" ]]; then
                SHOW_ACTIVE_ONLY=0
                continue
            else
                return
            fi
        fi
        
        local current_index=1
        local window_size=20
        
        while true; do
            clear_screen
            print_line
            if [[ "$SHOW_ACTIVE_ONLY" == "1" ]]; then
                printf "  ${BG_CYAN}  INTERACTIVE APP EXPLORER | App %d of %d | Filter: ACTIVE APPS ONLY                                   ${RESET}\n" "$current_index" "$total_apps"
            else
                printf "  ${BG_CYAN}  INTERACTIVE APP EXPLORER | App %d of %d | Filter: ALL DB APPS                                        ${RESET}\n" "$current_index" "$total_apps"
            fi
            print_line
            echo ""
            
            local half_window=$((window_size / 2))
            local start_idx=$((current_index - half_window))
            [[ $start_idx -lt 1 ]] && start_idx=1
            local end_idx=$((start_idx + window_size - 1))
            
            if [[ $end_idx -gt $total_apps ]]; then
                end_idx=$total_apps
                start_idx=$((end_idx - window_size + 1))
                [[ $start_idx -lt 1 ]] && start_idx=1
            fi
            
            for i in $(seq $start_idx $end_idx); do
                if [[ $i -eq $current_index ]]; then
                    printf "   ${BG_CYAN}${TXT_WHT} > %s ${RESET}\n" "${app_list[$i]}"
                else
                    printf "      %s\n" "${app_list[$i]}"
                fi
            done
            
            echo ""
            print_separator
            printf "  ${BOLD}Controls:${RESET} ${TXT_GRN}[W]${RESET} Up   ${TXT_GRN}[S]${RESET} Down   ${TXT_CYAN}[A]${RESET} PgUp   ${TXT_CYAN}[D]${RESET} PgDn   ${TXT_YEL}[E]${RESET}xecute   ${TXT_MAG}[T]${RESET}oggle Filter   ${TXT_RED}[B]${RESET}ack\n"
            print_separator
            
            read -n 1 -s nav_choice
            case "${nav_choice^^}" in
                W)
                    [[ $current_index -gt 1 ]] && current_index=$((current_index - 1))
                    ;;
                S)
                    [[ $current_index -lt $total_apps ]] && current_index=$((current_index + 1))
                    ;;
                A)
                    current_index=$((current_index - 10))
                    [[ $current_index -lt 1 ]] && current_index=1
                    ;;
                D)
                    current_index=$((current_index + 10))
                    [[ $current_index -gt $total_apps ]] && current_index=$total_apps
                    ;;
                T)
                    if [[ "$SHOW_ACTIVE_ONLY" == "0" ]]; then
                        SHOW_ACTIVE_ONLY=1
                    else
                        SHOW_ACTIVE_ONLY=0
                    fi
                    break
                    ;;
                B)
                    return
                    ;;
                E)
                    explorer_action "${app_pkg[$current_index]}"
                    cache_device_state
                    break
                    ;;
            esac
        done
    done
}

explorer_action() {
    local sel_pkg="$1"
    get_app_name "$sel_pkg"
    local sel_lbl="$APP_LABEL"
    
    while true; do
        check_app_state "$sel_pkg"
        
        clear_screen
        print_line
        printf "  ${BG_CYAN}  APP MANAGEMENT PANEL                                                                                               ${RESET}\n"
        print_line
        echo ""
        printf "  ${BOLD}App Name:${RESET}    ${TXT_WHT}%s${RESET}\n" "$sel_lbl"
        printf "  ${BOLD}Package ID:${RESET}  ${TXT_WHT}%s${RESET}\n" "$sel_pkg"
        printf "  ${BOLD}App Status:${RESET}  ${APP_STATE_COLOR}%s${RESET}\n" "$APP_STATE"
        echo ""
        print_separator
        printf "  ${TXT_GRN}[F]${RESET} Safe Remove (Uninstall for User 0 - Recommended for HyperOS)\n"
        printf "  ${TXT_CYAN}[R]${RESET} Unfreeze / Restore App\n"
        printf "  ${TXT_YEL}[B]${RESET} Back to App List\n"
        echo ""
        printf "  Press ${TXT_GRN}[F]${RESET}, ${TXT_CYAN}[R]${RESET}, or ${TXT_YEL}[B]${RESET}ack...\n"
        
        read -n 1 -s act_choice
        case "${act_choice^^}" in
            B)
                return
                ;;
            F)
                echo ""
                printf "  ${TXT_GRAY}Executing: pm uninstall -k --user 0 %s...${RESET}\n" "$sel_pkg"
                $ADB_CMD -s "$TARGET_ID" shell pm uninstall -k --user 0 "$sel_pkg" >/dev/null 2>&1 || true
                printf "  ${TXT_GRN}[OK] Safe Uninstall command sent.${RESET}\n"
                echo "$(date '+%H:%M:%S') | UNINSTALL-K | $sel_pkg | Interactive Explorer" >> "$LOGFILE"
                cache_device_state
                sleep 1
                ;;
            R)
                echo ""
                printf "  ${TXT_GRAY}Executing: cmd package install-existing %s...${RESET}\n" "$sel_pkg"
                $ADB_CMD -s "$TARGET_ID" shell cmd package install-existing "$sel_pkg" >/dev/null 2>&1 || true
                printf "  ${TXT_GRAY}Executing: pm enable %s...${RESET}\n" "$sel_pkg"
                $ADB_CMD -s "$TARGET_ID" shell pm enable "$sel_pkg" >/dev/null 2>&1 || true
                printf "  ${TXT_GRN}[OK] App Restored / Unfrozen.${RESET}\n"
                echo "$(date '+%H:%M:%S') | RESTORE | $sel_pkg | Interactive Explorer" >> "$LOGFILE"
                cache_device_state
                sleep 1
                ;;
        esac
    done
}

# ===============================================================================================
#  MODE SELECT
# ===============================================================================================

mode_select() {
    clear_screen
    echo ""
    print_line
    printf "  ${BOLD}${TXT_WHT}  STEP 2: SELECT OPERATION MODE${RESET}\n"
    print_line
    echo ""
    printf "  Please select your preferred debloat method:\n"
    echo ""
    printf "  ${TXT_GRN}[S]${RESET}afe Remove / Freeze ${TXT_GRAY}(Highly Recommended for HyperOS)${RESET}\n"
    print_separator
    printf "  Uses \"uninstall -k --user 0\" to bypass HyperOS SecurityExceptions.\n"
    printf "  Apps are hidden and stopped, but the APK remains on the system partition.\n"
    printf "  You can restore apps instantly via the Restore menu with no data loss.\n"
    echo ""
    printf "  ${TXT_CYAN}[R]${RESET}estore ${TXT_GRAY}(Recovery Mode)${RESET}\n"
    print_separator
    printf "  Re-enables frozen apps or reinstalls safely removed apps.\n"
    echo ""
    print_separator
    printf "  Press ${TXT_GRN}[S]${RESET} to Safe Remove, or ${TXT_CYAN}[R]${RESET} to Restore...\n"
    
    read -n 1 -s choice
    case "${choice^^}" in
        R)
            CMD_ACTION="RESTORE"
            MODE_NAME="RESTORE"
            MODE_VERB="Restore"
            LOG_MODE="RESTORED"
            apps_p4="$apps_p4 $apps_restore_only"
            ;;
        *)
            CMD_ACTION="pm uninstall -k --user 0"
            MODE_NAME="SAFE_REMOVE"
            MODE_VERB="Safe Remove"
            LOG_MODE="REMOVED_USER_0"
            ;;
    esac
    
    echo "Mode Selected: $MODE_NAME" >> "$LOGFILE"
    echo "--------------------------------------------------------" >> "$LOGFILE"
    
    preferences_init
}

# ===============================================================================================
#  PREFERENCES
# ===============================================================================================

preferences_init() {
    clear_screen
    echo ""
    print_line
    printf "  ${BOLD}${TXT_WHT}  STEP 3: PREFERENCES & PREVIEW${RESET}\n"
    print_line
    echo ""
    printf "  ${TXT_CYAN}[1] Smart Filtering (Context-Aware Auto-Skip)${RESET}\n"
    printf "      Debloat Mode: Automatically skips apps that are already uninstalled or frozen.\n"
    printf "      Restore Mode: Automatically skips apps that are already active.\n"
    printf "      ${TXT_GRN}(Uses high-speed local cache)${RESET}\n"
    echo ""
    printf "  Press ${TXT_GRN}[Y]${RESET}es to Enable or ${TXT_RED}[N]${RESET}o to Disable...\n"
    
    read -n 1 -s choice
    case "${choice^^}" in
        N)
            SKIP_NOT_INSTALLED=0
            printf "  -> ${TXT_RED}Smart Filtering Disabled.${RESET}\n"
            ;;
        *)
            SKIP_NOT_INSTALLED=1
            printf "  -> ${TXT_GRN}Smart Filtering Enabled.${RESET}\n"
            ;;
    esac
    
    echo ""
    print_separator
    echo ""
    printf "  ${TXT_CYAN}[2] Debloat Collection Preview${RESET}\n"
    printf "      Do you want to see the full list of apps that will be processed before we begin?\n"
    echo ""
    printf "  ${TXT_YEL}[Y]${RESET}es, show full list of apps to be processed.\n"
    printf "  ${TXT_YEL}[N]${RESET}o, skip preview and start immediately.\n"
    echo ""
    printf "  Press ${TXT_YEL}[Y]${RESET} or ${TXT_YEL}[N]${RESET}...\n"
    
    read -n 1 -s choice
    case "${choice^^}" in
        Y)
            clear_screen
            echo ""
            printf "  ${BG_GRN}  SAFE LIST (PHASE 1)                                                                                               ${RESET}\n"
            printf "  ${TXT_GRAY}  (Ads, Analytics, Services, Stubs)${RESET}\n"
            for app in $apps_p1; do
                echo "   - $app"
            done
            echo ""
            printf "  ${BG_YEL}  ADVANCED LIST (PHASE 2)                                                                                           ${RESET}\n"
            printf "  ${TXT_GRAY}  (User Apps: Gallery, Weather, Tools)${RESET}\n"
            for app in $apps_p2; do
                echo "   - $app"
            done
            echo ""
            printf "  ${BG_RED}  RISKY SYSTEM APPS (PHASE 3)                                                                                       ${RESET}\n"
            printf "  ${TXT_GRAY}  (HyperOS Core: App Vault, Find Device, Themes, Security, GetApps)${RESET}\n"
            for app in $apps_p3; do
                echo "   - $app"
            done
            echo ""
            printf "  ${BG_MAG}  HIDDEN SYSTEM APPS (PHASE 4)                                                                                      ${RESET}\n"
            printf "  ${TXT_GRAY}  (Background APIs and Hidden Telemetry)${RESET}\n"
            for app in $apps_p4; do
                echo "   - $app"
            done
            echo ""
            printf "  ${TXT_GRAY}  Press any key to begin processing...${RESET}\n"
            wait_key
            ;;
    esac
    
    phase1_init
}

# ===============================================================================================
#  PHASE 1: SAFE APPS
# ===============================================================================================

phase1_init() {
    clear_screen
    echo ""
    print_line
    printf "  ${BOLD}${TXT_WHT}  PHASE 1/4 ${TXT_GRN}|${TXT_WHT} Ads, Analytics & Junk Services${RESET}\n"
    printf "  ${TXT_GRAY}  Phase 1 of 4 in total${RESET}\n"
    print_line
    echo ""
    printf "  ${BG_GRN}  SELECT MODE                                                                                                       ${RESET}\n"
    echo ""
    printf "  ${TXT_GRN}[A]${RESET}uto Process All Apps ${TXT_RED}(Risky)${RESET}\n"
    printf "  ${TXT_GRN}[M]${RESET}anual Review Every App ${TXT_GRAY}(Recommended)${RESET}\n"
    printf "  ${TXT_GRN}[S]${RESET}kip Phase #1 ${TXT_GRAY}(Proceed to Phase #2)${RESET}\n"
    echo ""
    printf "  Press ${TXT_GRN}[A]${RESET}, ${TXT_GRN}[M]${RESET} or ${TXT_GRN}[S]${RESET}...\n"
    
    read -n 1 -s choice
    PHASE1_CHOICE="${choice^^}"
    
    if [[ "$PHASE1_CHOICE" == "S" ]]; then
        phase2_init
        return
    fi
    
    if [[ "$PHASE1_CHOICE" == "M" ]]; then
        clear_screen
        echo ""
        printf "  ${BG_GRN}  MANUAL MODE ENGAGED                                                                                               ${RESET}\n"
        echo ""
        printf "  ${TXT_GRAY}Press any key to start...${RESET}\n"
        wait_key
    fi
    
    THEME_BG="$BG_GRN"
    for pkg in $apps_p1; do
        get_app_name "$pkg"
        if [[ "$PHASE1_CHOICE" == "A" ]]; then
            execute_action "$pkg" "$APP_LABEL" "SAFE"
        else
            ask_user "$pkg" "$APP_LABEL" "SAFE"
        fi
    done
    
    phase2_init
}

# ===============================================================================================
#  PHASE 2: ADVANCED APPS
# ===============================================================================================

phase2_init() {
    clear_screen
    echo ""
    print_line
    printf "  ${BOLD}${TXT_WHT}  PHASE 2/4 ${TXT_YEL}|${TXT_WHT} User Tools & Features${RESET}\n"
    printf "  ${TXT_GRAY}  Phase 2 of 4 in total${RESET}\n"
    print_line
    echo ""
    printf "  ${BG_YEL}  SELECT MODE                                                                                                       ${RESET}\n"
    echo ""
    printf "  These apps are visible on your home screen (Gallery, Weather, File Manager, etc).\n"
    printf "  Only remove them if you have a replacement app installed.\n"
    echo ""
    printf "  ${TXT_YEL}[A]${RESET}uto Process All Apps ${TXT_RED}(Risky)${RESET}\n"
    printf "  ${TXT_YEL}[M]${RESET}anual Review Every App ${TXT_GRN}(Recommended)${RESET}\n"
    printf "  ${TXT_YEL}[S]${RESET}kip Phase #2 ${TXT_GRAY}(Proceed to Phase #3)${RESET}\n"
    echo ""
    printf "  Press ${TXT_YEL}[A]${RESET}, ${TXT_YEL}[M]${RESET} or ${TXT_YEL}[S]${RESET}...\n"
    
    read -n 1 -s choice
    PHASE2_CHOICE="${choice^^}"
    
    if [[ "$PHASE2_CHOICE" == "S" ]]; then
        phase3_init
        return
    fi
    
    if [[ "$PHASE2_CHOICE" == "M" ]]; then
        clear_screen
        echo ""
        printf "  ${BG_YEL}  MANUAL MODE ENGAGED                                                                                               ${RESET}\n"
        echo ""
        printf "  ${TXT_GRAY}Press any key to start...${RESET}\n"
        wait_key
    fi
    
    THEME_BG="$BG_YEL"
    for pkg in $apps_p2; do
        get_app_name "$pkg"
        if [[ "$PHASE2_CHOICE" == "A" ]]; then
            execute_action "$pkg" "$APP_LABEL" "CAUTION"
        else
            ask_user "$pkg" "$APP_LABEL" "CAUTION"
        fi
    done
    
    phase3_init
}

# ===============================================================================================
#  PHASE 3: RISKY SYSTEM APPS
# ===============================================================================================

phase3_init() {
    clear_screen
    echo ""
    print_line
    printf "  ${BOLD}${TXT_WHT}  PHASE 3/4 ${TXT_RED}|${TXT_WHT} Risky System Apps${RESET}\n"
    printf "  ${TXT_GRAY}  Phase 3 of 4 in total${RESET}\n"
    print_line
    echo ""
    printf "  ${BG_RED}  SELECT MODE                                                                                                       ${RESET}\n"
    echo ""
    printf "  Contains HyperOS core apps (App Vault, Security, GetApps, Themes).\n"
    printf "  Removing some of these may cause bootloops on certain firmware versions!\n"
    echo ""
    printf "  ${TXT_RED}[A]${RESET}uto Process All Apps ${TXT_RED}(Risky)${RESET}\n"
    printf "  ${TXT_RED}[M]${RESET}anual Review Every App ${TXT_GRN}(Recommended)${RESET}\n"
    printf "  ${TXT_RED}[S]${RESET}kip Phase #3 ${TXT_GRAY}(Proceed to Phase #4)${RESET}\n"
    echo ""
    printf "  Press ${TXT_RED}[A]${RESET}, ${TXT_RED}[M]${RESET} or ${TXT_RED}[S]${RESET}...\n"
    
    read -n 1 -s choice
    PHASE3_CHOICE="${choice^^}"
    
    if [[ "$PHASE3_CHOICE" == "S" ]]; then
        phase4_init
        return
    fi
    
    if [[ "$PHASE3_CHOICE" == "M" ]]; then
        clear_screen
        echo ""
        printf "  ${BG_RED}  MANUAL MODE ENGAGED                                                                                               ${RESET}\n"
        echo ""
        printf "  ${TXT_GRAY}Press any key to start...${RESET}\n"
        wait_key
    fi
    
    THEME_BG="$BG_RED"
    for pkg in $apps_p3; do
        get_app_name "$pkg"
        if [[ "$PHASE3_CHOICE" == "A" ]]; then
            execute_action "$pkg" "$APP_LABEL" "DANGER"
        else
            ask_user "$pkg" "$APP_LABEL" "DANGER"
        fi
    done
    
    phase4_init
}

# ===============================================================================================
#  PHASE 4: HIDDEN SYSTEM APPS
# ===============================================================================================

phase4_init() {
    clear_screen
    echo ""
    print_line
    printf "  ${BOLD}${TXT_WHT}  PHASE 4/4 ${TXT_MAG}|${TXT_WHT} Hidden System Apps (Canta Suggestions)${RESET}\n"
    printf "  ${TXT_GRAY}  Phase 4 of 4 in total${RESET}\n"
    print_line
    echo ""
    printf "  ${BG_MAG}  SELECT MODE                                                                                                       ${RESET}\n"
    echo ""
    printf "  These are hidden APIs, Android core bloat, and Xiaomi telemetry.\n"
    printf "  Usually safe, but might break specific deep-system functions.\n"
    echo ""
    printf "  ${TXT_MAG}[A]${RESET}uto Process All Apps ${TXT_RED}(Risky)${RESET}\n"
    printf "  ${TXT_MAG}[M]${RESET}anual Review Every App ${TXT_GRN}(Recommended)${RESET}\n"
    printf "  ${TXT_MAG}[S]${RESET}kip Phase #4 ${TXT_GRAY}(Proceed to Finish)${RESET}\n"
    echo ""
    printf "  Press ${TXT_MAG}[A]${RESET}, ${TXT_MAG}[M]${RESET} or ${TXT_MAG}[S]${RESET}...\n"
    
    read -n 1 -s choice
    PHASE4_CHOICE="${choice^^}"
    
    if [[ "$PHASE4_CHOICE" == "S" ]]; then
        finish_and_exit
        return
    fi
    
    if [[ "$PHASE4_CHOICE" == "M" ]]; then
        clear_screen
        echo ""
        printf "  ${BG_MAG}  MANUAL MODE ENGAGED                                                                                               ${RESET}\n"
        echo ""
        printf "  ${TXT_GRAY}Press any key to start...${RESET}\n"
        wait_key
    fi
    
    THEME_BG="$BG_MAG"
    for pkg in $apps_p4; do
        get_app_name "$pkg"
        if [[ "$PHASE4_CHOICE" == "A" ]]; then
            execute_action "$pkg" "$APP_LABEL" "HIDDEN"
        else
            ask_user "$pkg" "$APP_LABEL" "HIDDEN"
        fi
    done
    
    finish_and_exit
}

# ===============================================================================================
#  START MAIN MENU
# ===============================================================================================

main_menu
