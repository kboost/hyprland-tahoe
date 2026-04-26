#!/usr/bin/env bash
# network.sh — info de red sin depender de NetworkManager
# Acciones:
#   icon       glifo Nerd Font según estado (wifi / ethernet / desconectado)
#   name       SSID, "Cableado" o "Desconectado"
#   iface      interfaz activa (e.g. ens18, wlp2s0)
#   local-ip   IPv4 local con CIDR
#   gateway    gateway por defecto
#   public-ip  IP pública (cacheada 5 min)
#   rx-speed   descarga humanizada
#   tx-speed   subida humanizada
#   signal     señal wifi (dBm) si aplica

CACHE_DIR="${XDG_RUNTIME_DIR:-/tmp}/eww-network"
mkdir -p "$CACHE_DIR"

iface=$(ip route 2>/dev/null | awk '/^default/ {print $5; exit}')

if [[ -n "$iface" && -d "/sys/class/net/$iface/wireless" ]]; then
    type="wifi"
elif [[ -n "$iface" ]]; then
    type="ethernet"
else
    type="none"
fi

humanize() {
    awk -v b="$1" 'BEGIN {
        if      (b >= 1048576) printf "%.1f MB/s\n", b/1048576
        else if (b >= 1024)    printf "%.1f KB/s\n", b/1024
        else                   printf "%d B/s\n",   b
    }'
}

case "$1" in
    icon)
        case "$type" in
            wifi)     echo "" ;;
            ethernet) echo "" ;;
            *)        echo "" ;;
        esac
        ;;
    name)
        if [[ "$type" == "wifi" ]] && command -v iw &>/dev/null; then
            iw dev "$iface" link 2>/dev/null | awk -F': ' '/SSID/{print $2; exit}'
        elif [[ "$type" == "ethernet" ]]; then
            echo "Cableado"
        else
            echo "Desconectado"
        fi
        ;;
    iface)
        echo "${iface:-—}"
        ;;
    local-ip)
        if [[ -z "$iface" ]]; then echo "—"; exit 0; fi
        ip -4 -br addr show "$iface" 2>/dev/null | awk '{print $3}' | head -1
        ;;
    gateway)
        ip route 2>/dev/null | awk '/^default/ {print $3; exit}'
        ;;
    public-ip)
        cache="$CACHE_DIR/public-ip"
        if [[ -f "$cache" ]] && (( $(date +%s) - $(stat -c %Y "$cache") < 300 )); then
            cat "$cache"
        else
            ip=$(timeout 3 curl -s ifconfig.me 2>/dev/null)
            if [[ -n "$ip" ]]; then
                echo "$ip" | tee "$cache"
            else
                echo "—"
            fi
        fi
        ;;
    rx-speed|tx-speed)
        if [[ -z "$iface" ]]; then echo "0 B/s"; exit 0; fi
        case "$1" in
            rx-speed) stat_file="rx_bytes" ;;
            tx-speed) stat_file="tx_bytes" ;;
        esac
        cur=$(cat "/sys/class/net/$iface/statistics/$stat_file" 2>/dev/null || echo 0)
        cur_ts=$(date +%s%3N)
        cache="$CACHE_DIR/${iface}-${stat_file}"
        speed=0
        if [[ -f "$cache" ]]; then
            read -r prev_val prev_ts < "$cache"
            delta_b=$(( cur - prev_val ))
            delta_ms=$(( cur_ts - prev_ts ))
            (( delta_ms < 1 )) && delta_ms=1
            speed=$(( delta_b * 1000 / delta_ms ))
            (( speed < 0 )) && speed=0
        fi
        echo "$cur $cur_ts" > "$cache"
        humanize "$speed"
        ;;
    signal)
        if [[ "$type" == "wifi" ]] && command -v iw &>/dev/null; then
            iw dev "$iface" link 2>/dev/null | awk '/signal:/ {print $2 " dBm"; exit}'
        else
            echo "—"
        fi
        ;;
esac
