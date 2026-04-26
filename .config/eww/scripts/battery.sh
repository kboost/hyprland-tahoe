#!/usr/bin/env bash
# battery.sh pct  → "87"
# battery.sh icon → glifo Nerd Font según nivel/estado

BAT=$(ls /sys/class/power_supply/ 2>/dev/null | grep -m1 -E '^BAT')

if [[ -z "$BAT" ]]; then
    case "$1" in
        pct)  echo "—" ;;
        icon) echo "" ;;   # enchufe (sin batería = desktop)
    esac
    exit 0
fi

CAP=$(cat "/sys/class/power_supply/$BAT/capacity" 2>/dev/null)
STAT=$(cat "/sys/class/power_supply/$BAT/status"   2>/dev/null)

case "$1" in
    pct) echo "$CAP" ;;
    icon)
        if [[ "$STAT" == "Charging" || "$STAT" == "Full" ]]; then
            echo ""
        else
            if   (( CAP >= 90 )); then echo ""
            elif (( CAP >= 70 )); then echo ""
            elif (( CAP >= 40 )); then echo ""
            elif (( CAP >= 15 )); then echo ""
            else                       echo ""
            fi
        fi
        ;;
esac
