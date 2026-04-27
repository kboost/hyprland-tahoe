#!/usr/bin/env bash
# Abre/cierra un popup eww junto con un catcher fullscreen invisible
# para que un click fuera del popup lo cierre.
# Uso: popup-toggle.sh <menu>

menu="$1"
all_menus=(powermenu netmenu volmenu)

if [[ -z "$menu" ]]; then
    echo "uso: $0 <menu>"
    exit 1
fi

active="$(eww active-windows 2>/dev/null | awk -F: '{print $1}')"

if grep -qx "$menu" <<<"$active"; then
    eww close "$menu" popup-catcher >/dev/null 2>&1
    exit 0
fi

for m in "${all_menus[@]}"; do
    [[ "$m" == "$menu" ]] && continue
    grep -qx "$m" <<<"$active" && eww close "$m" >/dev/null 2>&1
done

eww open popup-catcher >/dev/null 2>&1
eww open "$menu" >/dev/null 2>&1
