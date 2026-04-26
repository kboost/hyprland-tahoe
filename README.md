# hyprland-tahoe

A macOS Tahoe-inspired rice for [Hyprland](https://hypr.land/) on Arch Linux.
Floating glass topbar (Waybar), macOS-style dock (nwg-dock-hyprland), liquid-glass
notifications (swaync), eww popups (powermenu / netmenu / volmenu), McMojave
cursors, and a forest wallpaper.

![preview](preview.png)

## Features

- **Floating Waybar** with rounded corners and Liquid Glass effect — Arch logo,
  workspace pills, active window, **dynamic island** (mpris + clock + weather),
  launchpad, tray, network, volume, battery, notifications, power.
- **Dynamic Island** with adaptive transitions and weather-aware hover
  animations — sun rays during the day, moon halo at night, falling drop for
  rain, lightning flashes for storms, frozen shimmer for cold/snow. The clock
  has a slow breathing glow and mpris pulses in cyan while playing.
- **Smart weather module** (`waybar/scripts/weather.sh`) — single request to
  `wttr.in` (j1), real sunrise/sunset to pick the day/night icon (sun ↔ moon),
  Spanish descriptions, full pango tooltip with feels-like temperature,
  humidity, wind, sunrise and sunset.
- **eww popups** triggered from the bar:
  - **Powermenu** — avatar, username, host, uptime, and entries for Settings,
    Lock, Suspend, Logout and Power off (cosmic-settings-style icons).
  - **Netmenu** — local IP, gateway, public IP and live download/upload
    speeds, derived from the kernel without depending on NetworkManager.
  - **Volmenu** — slider with mute toggle, current sink name, percentage.
- **nwg-dock-hyprland** dock at the bottom in resident mode with glass styling.
- **swaync** notifications and control center themed to match (translucent,
  rounded, soft shadows, Apple-style close buttons).
- **McMojave cursors** from [vinceliuice/McMojave-cursors](https://github.com/vinceliuice/McMojave-cursors).
- **Forest wallpaper** ("Forest in Bavaria" by Sebastian Unrau, via Unsplash).
- **swaybg** as the wallpaper daemon (works on QEMU/virtio where hyprpaper fails
  with EGL errors).

## Requirements

- Arch Linux (or any Arch-based distro with `pacman`)
- An active Hyprland session (or willingness to log into one)

## Install

```bash
git clone https://github.com/<your-user>/hyprland-tahoe ~/hyprland-tahoe
cd ~/hyprland-tahoe
chmod +x install.sh
./install.sh
```

The installer will:

1. Install required packages from the official repos.
2. Back up your current `~/.config/{hypr,waybar,nwg-dock-hyprland,swaync}` to
   `~/.config/backup-<timestamp>/`.
3. Copy the new configs into place.
4. Download the forest wallpaper to `~/Pictures/Wallpapers/forest.jpg`.
5. Clone and install McMojave cursors into `~/.local/share/icons/`.
6. Write `~/.config/gtk-3.0/settings.ini` to use the new cursor.

After that, log into a Hyprland session.

## Customization

### Weather city

The weather defaults to **La Serena, Chile**. Change it in
`~/.config/waybar/scripts/weather.sh`:

```bash
LOCATION="La+Serena"        # use + for spaces, e.g. "Buenos+Aires"
LOCATION_PRETTY="La Serena" # display name in the tooltip
```

The script does a single `wttr.in?format=j1` request, then derives the temperature,
weather description, sunrise/sunset and day/night state. Reload with
`pkill -SIGRTMIN+8 waybar` to refresh without a full restart, or `pkill waybar &&
waybar &` for a hard restart.

### Cold threshold

The frozen-shimmer animation triggers when the temperature drops below 5°C.
Edit `COLD_THRESHOLD` at the top of `weather.sh` to adjust.

### Locale (date in Spanish)

The clock tooltip shows the date with whatever locale your system has. To get
day and month names in Spanish, generate the locale:

```bash
sudo sed -i 's/^#es_CL.UTF-8/es_CL.UTF-8/' /etc/locale.gen
sudo locale-gen
```

Then add `"locale": "es_CL.UTF-8"` to the `clock` block in
`~/.config/waybar/config`.

### Dock pinned apps

`nwg-dock-hyprland` doesn't read pinned apps from a config file. To pin:

1. Open the app (kitty, firefox, nautilus, etc.).
2. Right-click on its icon in the dock.
3. Choose **Pin**.

Pinned apps are stored in `~/.cache/nwg-dock-hyprland/pinned`.

### Wallpaper

Replace `~/Pictures/Wallpapers/forest.jpg` with any image, then restart swaybg:

```bash
pkill swaybg && swaybg -i ~/Pictures/Wallpapers/forest.jpg -m fill &
```

## Layout

```
~/.config/
├── hypr/
│   ├── hyprland.conf       # main compositor config + autostart + blur layerrules
│   ├── hypridle.conf       # idle/lock timing
│   ├── hyprlock.conf       # lock screen
│   └── hyprpaper.conf      # kept for reference (swaybg is used at runtime)
├── waybar/
│   ├── config              # modules + behaviour
│   ├── style.css           # Tahoe glass styling + dynamic island animations
│   └── scripts/
│       └── weather.sh      # wttr.in JSON, day/night, weather class, tooltip
├── eww/
│   ├── eww.yuck            # popup definitions (powermenu, netmenu, volmenu)
│   ├── eww.scss            # popup styling
│   └── scripts/
│       ├── network.sh      # NetworkManager-free net info
│       ├── volume.sh       # wpctl wrapper
│       ├── battery.sh      # /sys/class/power_supply
│       └── active-window.sh
├── nwg-dock-hyprland/
│   └── style.css           # dock styling
└── swaync/
    ├── config.json         # control center behaviour
    └── style.css           # control center + popup styling
```

## Dynamic Island animations

All animations live in `~/.config/waybar/style.css` as `@keyframes` blocks.
They are driven by classes set on the weather module by `weather.sh`:

| Class           | When                                    | Animation                         |
| --------------- | --------------------------------------- | --------------------------------- |
| `day`           | Sun is up                               | Warm sun rays glow on hover       |
| `night`         | Sun is down                             | Cool moon halo on hover           |
| `rain`          | weatherCode 176/263/293/.../359         | Falling blue drop pulse on hover  |
| `storm`         | weatherCode 200/386/389/392/395         | Lightning flash on hover          |
| `snow`/`sleet`  | weatherCode 227/230/3xx                 | Frozen icy shimmer on hover       |
| `cold`          | temp ≤ 5°C (additive)                   | Frozen shimmer on hover           |

Independent of weather, the **clock** breathes once every 4 s and **mpris**
pulses cyan while playing. Hovering any of the three pills (mpris, clock,
weather) expands its padding with a `cubic-bezier(0.32, 0.72, 0, 1)` easing
curve (the iOS spring) — that is the "adaptive" island behaviour.

## Notes

- Glyphs come from `JetBrainsMono Nerd Font`. The configs embed them as raw
  UTF-8 bytes (e.g. ``, ``, ``) in the Private Use Area
  (`U+F000`–`U+F8FF`). If you copy these files through an editor or clipboard
  that strips non-renderable characters, the glyphs may disappear and you will
  see empty squares — re-paste them or run `python3` with the codepoints
  (`chr(0xF013)` etc.) to restore them.
- The eww SCSS uses **only ASCII** in comments. Non-ASCII chars in comments
  cause `grass-rs` to inject `@charset "UTF-8";` into the compiled CSS, which
  GTK CSS rejects with "unknown @ rule".
- Hyprland blur for eww popups requires both a `layerrule { blur = true; ... }`
  matching the namespace and an `hyprctl reload` after the rule is added.
- `hyprpaper` is replaced by `swaybg` because `hyprpaper` fails on QEMU/virtio
  with `eglQueryDeviceStringEXT EGL_BAD_PARAMETER`. On bare metal you can switch
  back by replacing `exec-once = swaybg ...` with `exec-once = hyprpaper` in
  `~/.config/hypr/hyprland.conf`.
- The cursor is set both in the Hyprland env (`XCURSOR_THEME`,
  `HYPRCURSOR_THEME`) and in `~/.config/gtk-3.0/settings.ini` so GTK apps pick
  it up too.

## Credits

- [Hyprland](https://hypr.land/) — the compositor
- [Waybar](https://github.com/Alexays/Waybar) and
  [kamlendras/waybar-config](https://github.com/kamlendras/waybar-config) for
  Sequoia inspiration
- [nwg-dock-hyprland](https://github.com/nwg-piotr/nwg-dock-hyprland) by
  nwg-piotr
- [swaync](https://github.com/ErikReider/SwayNotificationCenter) by ErikReider
- [McMojave-cursors](https://github.com/vinceliuice/McMojave-cursors) by
  vinceliuice
- "Forest in Bavaria" by Sebastian Unrau on Unsplash

## License

MIT — see [LICENSE](LICENSE).
