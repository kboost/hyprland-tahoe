#!/usr/bin/env bash
# Emite el título de la ventana activa cada vez que cambia.
# Pensado para deflisten en EWW.

print_active() {
    local title
    title=$(hyprctl activewindow -j 2>/dev/null | jq -r '.title // empty')
    if [[ -z "$title" ]]; then
        echo "Escritorio"
    else
        # recorta a 60 chars para no romper la barra
        echo "${title:0:60}"
    fi
}

print_active

# Suscribirse al socket de eventos de Hyprland
SOCK="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
if [[ -S "$SOCK" ]]; then
    socat -U - UNIX-CONNECT:"$SOCK" 2>/dev/null | while read -r line; do
        case "$line" in
            activewindow*|workspace*|focusedmon*)
                print_active
                ;;
        esac
    done
fi
