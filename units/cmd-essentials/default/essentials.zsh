# Environment
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"


# Init
eval "$(mise activate zsh)"


# Aliases
# Servers often don't know TERM=foot; skip with `command ssh` on hosts that have its terminfo
alias ssh='TERM=xterm-256color ssh'


# Functions
open() {
  xdg-open "$@" >/dev/null 2>&1 &
}

n() { if [ "$#" -eq 0 ]; then nvim .; else nvim "$@"; fi; }

# Downloads with yt-dlp, defaults in ~/.config/yt-dlp/config. Without a URL they use the clipboard.
_yt-url() { print -r -- "${1:-$(wl-paste -n 2>/dev/null)}"; }

# Video in up to 1080p: yt [url] [max height]
yt() {
  yt-dlp ${2:+-S} ${2:+res:$2} -- "$(_yt-url "$1")"
}

# Audio only, as mp3 in ~/Music: yt-audio [url]
yt-audio() {
  yt-dlp -x --audio-format mp3 --audio-quality 0 -f ba/b \
    --no-write-subs --no-embed-subs -P ~/Music -- "$(_yt-url "$1")"
}

# Only part of a video: yt-clip [url] 1:20 2:05
yt-clip() {
  local url
  if (( $# == 2 )); then url="$(_yt-url)"; else url="$1"; shift; fi
  yt-dlp --download-sections "*$1-$2" --force-keyframes-at-cuts --no-write-subs --no-embed-subs \
    -o "%(title)s [%(id)s] ${1//:/.}-${2//:/.}.%(ext)s" -- "$url"
}

# A whole playlist into its own folder, numbered: yt-list [url]
yt-list() {
  yt-dlp --yes-playlist -o '%(playlist_title)s/%(playlist_index)03d - %(title)s [%(id)s].%(ext)s' \
    -- "$(_yt-url "$1")"
}


# Video helpers, output goes next to the input

# Cut exactly, re-encoded at near-original quality (LosslessCut cuts without re-encoding):
# video-trim in.mp4 1:20 2:05
video-trim() {
  ffmpeg -ss "$2" -to "$3" -i "$1" -c:v libx264 -preset fast -crf 18 -pix_fmt yuv420p \
    -c:a aac -b:a 192k -movflags +faststart "${1%.*}-trim.mp4"
}

# Audio track as mp3: video-audio in.mp4
video-audio() {
  ffmpeg -i "$1" -vn -q:a 0 "${1%.*}.mp3"
}

# Remove the audio: video-mute in.mp4
video-mute() {
  ffmpeg -i "$1" -map 0 -map -0:a -c copy "${1%.*}-mute.${1##*.}"
}

# GIF, 640px wide by default: video-gif in.mp4 [width]
video-gif() {
  ffmpeg -i "$1" -vf "fps=15,scale=${2:-640}:-2:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse" \
    "${1%.*}.gif"
}

# Smaller H.264 mp4 for sharing, higher crf = smaller: video-shrink in.mp4 [crf, default 28]
video-shrink() {
  ffmpeg -i "$1" -c:v libx264 -preset slow -crf "${2:-28}" -pix_fmt yuv420p -c:a aac -b:a 128k \
    -movflags +faststart "${1%.*}-small.mp4"
}

# Faster or slower, audio pitch kept: video-speed in.mp4 2 (or 0.5)
video-speed() {
  ffmpeg -i "$1" -vf "setpts=PTS/$2" -af "atempo=$2" "${1%.*}-x$2.${1##*.}"
}


# Yazi, and stay in the directory it was in when it quits
y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  # Remote folders (sftp://) can't be cd'd into
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && [[ "$cwd" != sftp://* ]] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}
