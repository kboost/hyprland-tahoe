#!/usr/bin/env bash
# Installer for hyprland-tahoe — macOS Tahoe-like rice for Hyprland on Arch Linux
# Usage:  ./install.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/backup-$(date +%Y%m%d-%H%M%S)"

c_blue()  { printf '\033[1;34m%s\033[0m\n' "$*"; }
c_green() { printf '\033[1;32m%s\033[0m\n' "$*"; }
c_red()   { printf '\033[1;31m%s\033[0m\n' "$*"; }

# 1. Check Arch / pacman
if ! command -v pacman >/dev/null; then
  c_red "Este instalador requiere Arch Linux (pacman)."
  exit 1
fi

c_blue "==> Instalando paquetes con pacman"
PKGS=(
  hyprland hyprpaper hyprlock hypridle
  waybar nwg-dock-hyprland swaybg swaync
  kitty wofi nautilus
  ttf-jetbrains-mono-nerd ttf-font-awesome
  wl-clipboard cliphist
  brightnessctl playerctl
  pavucontrol nm-connection-editor
  polkit-gnome
  jq grim slurp
  curl git
)
sudo pacman -S --needed --noconfirm "${PKGS[@]}"

# 2. Backup existing configs
c_blue "==> Backup de configs existentes en $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
for d in hypr waybar nwg-dock-hyprland swaync; do
  if [[ -d "$HOME/.config/$d" ]]; then
    cp -r "$HOME/.config/$d" "$BACKUP_DIR/" 2>/dev/null || true
  fi
done
c_green "    backup en $BACKUP_DIR"

# 3. Copy new configs
c_blue "==> Copiando configs nuevos a ~/.config/"
mkdir -p "$HOME/.config"
cp -r "$REPO_DIR/.config/." "$HOME/.config/"
c_green "    configs copiadas"

# 4. Download forest wallpaper
c_blue "==> Descargando wallpaper Forest in Bavaria (Unsplash, ~1.7MB)"
mkdir -p "$HOME/Pictures/Wallpapers"
WP="$HOME/Pictures/Wallpapers/forest.jpg"
if [[ ! -f "$WP" ]]; then
  curl -L --max-time 60 -o "$WP" \
    "https://images.unsplash.com/photo-1448375240586-882707db888b?w=3840&q=85&fm=jpg"
  c_green "    wallpaper en $WP"
else
  c_green "    wallpaper ya presente, skip"
fi

# 5. Install McMojave cursors
c_blue "==> Instalando cursor McMojave"
if [[ ! -d "$HOME/.local/share/icons/McMojave-cursors" ]]; then
  TMP=$(mktemp -d)
  git clone --depth 1 https://github.com/vinceliuice/McMojave-cursors "$TMP" >/dev/null 2>&1
  ( cd "$TMP" && bash install.sh )
  rm -rf "$TMP"
  c_green "    cursor instalado en ~/.local/share/icons/McMojave-cursors"
else
  c_green "    cursor ya instalado, skip"
fi

# 6. GTK cursor settings
c_blue "==> Configurando GTK cursor"
mkdir -p "$HOME/.config/gtk-3.0"
cat > "$HOME/.config/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-cursor-theme-name=McMojave-cursors
gtk-cursor-theme-size=24
EOF
c_green "    ~/.config/gtk-3.0/settings.ini"

c_green ""
c_green "════════════════════════════════════════════"
c_green "  Instalación completa"
c_green "════════════════════════════════════════════"
echo
echo "Siguientes pasos:"
echo "  1. Inicia sesión en Hyprland (TTY → 'Hyprland')"
echo "     o reinicia tu sesión si ya estás en Hyprland."
echo "  2. Para pinear apps al dock: abre la app, click derecho"
echo "     en su icono del dock → Pin."
echo "  3. El clima por defecto es La Serena, Chile. Para cambiarlo:"
echo "     edita ~/.config/waybar/config → modulo custom/weather → URL wttr.in/<TuCiudad>"
echo
echo "Tu config previa se guardó en: $BACKUP_DIR"
