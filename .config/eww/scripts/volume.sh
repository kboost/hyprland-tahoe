#!/usr/bin/env bash
# volume.sh
#   pct        → "42"
#   icon       → glifo Nerd Font según nivel/mute
#   muted      → "0" / "1"
#   sink-name  → descripción humana del sink (e.g. "Built-in Audio Analog Stereo")
#   set <N>    → fija volumen al N % (clamp 0-150)
#   toggle     → toggle mute

read -r _ vol _ < <(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q MUTED && echo 1 || echo 0)
pct=$(awk -v v="$vol" 'BEGIN{printf "%d", v*100}')

case "$1" in
    pct) echo "$pct" ;;
    icon)
        if [[ "$muted" == "1" ]]; then echo ""
        elif (( pct >= 66 )); then     echo ""
        elif (( pct >= 33 )); then     echo ""
        elif (( pct >  0 )); then      echo ""
        else                            echo ""
        fi
        ;;
    muted)
        echo "$muted"
        ;;
    sink-name)
        wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null \
            | awk -F'"' '/node\.description/ {print $2; exit}' \
            | head -c 40
        echo
        ;;
    set)
        val="$2"
        [[ -z "$val" ]] && exit 1
        # Limita 0-150 para evitar valores extremos
        (( val < 0 ))   && val=0
        (( val > 150 )) && val=150
        # Si está muteado y el usuario mueve el slider, desmutea
        if [[ "$muted" == "1" && "$val" -gt 0 ]]; then
            wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
        fi
        wpctl set-volume @DEFAULT_AUDIO_SINK@ "${val}%"
        ;;
    toggle)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
esac
