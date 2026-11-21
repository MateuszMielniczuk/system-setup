# Sourced by screenshot.sh and ocr.sh
# capture_region FILE: freeze the screen (hyprpicker overlay), let the user select
# a region with slurp and save it from the frozen image. Fails if selection is cancelled.
capture_region() {
  local out="$1" pid="" geom rc
  if command -v hyprpicker >/dev/null; then
    hyprpicker -r -z >/dev/null 2>&1 &
    pid=$!
    sleep 0.15
  fi
  geom=$(slurp)
  rc=$?
  [[ $rc -eq 0 ]] && { grim -g "$geom" "$out"; rc=$?; }
  [[ -n "$pid" ]] && kill "$pid" 2>/dev/null
  return $rc
}
