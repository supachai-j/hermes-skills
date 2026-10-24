#!/usr/bin/env bash
# Dry-run by default. Pass --apply to delete. Prints counts only, never file contents.
# Required for snapshot pruning: SNAP_LABEL (the -l label your backup job uses, e.g. daily-auto).
# Optional: KEEP (default 7), AGE (days, default 14), HERMES_HOME.
set -uo pipefail
APPLY=0; [ "${1:-}" = "--apply" ] && APPLY=1
H="${HERMES_HOME:-$HOME/.hermes}"; KEEP="${KEEP:-7}"; AGE="${AGE:-14}"
case "$KEEP$AGE" in *[!0-9]*) echo "KEEP/AGE must be integers"; exit 2;; esac
[ "$KEEP" -ge 3 ] || { echo "refusing KEEP<3"; exit 2; }
[ -d "$H" ] || { echo "no Hermes home at $H"; exit 1; }
mode=$([ $APPLY -eq 1 ] && echo APPLY || echo DRY-RUN)
log=()
# 1) snapshots with the given label only (never touches manual / pre-update snapshots)
if [ -n "${SNAP_LABEL:-}" ] && [ -d "$H/state-snapshots" ]; then
  mapfile -t snaps < <(ls -1 "$H/state-snapshots" | grep -E "^[0-9]{8}-[0-9]{6}-${SNAP_LABEL}\$" | sort -r)
  n=0
  for s in "${snaps[@]:$KEEP}"; do
    n=$((n+1)); [ $APPLY -eq 1 ] && rm -rf -- "$H/state-snapshots/$s"
  done
  log+=("snapshots[$SNAP_LABEL]: ${#snaps[@]} found, $n pruned, keep $KEEP")
else
  log+=("snapshots: skipped (set SNAP_LABEL to enable)")
fi
# 2) old hand-made backups of credential/config files (top level of home and each profile)
b=0
while IFS= read -r f; do
  b=$((b+1)); [ $APPLY -eq 1 ] && rm -f -- "$f"
done < <(find "$H" "$H"/profiles/* -maxdepth 1 -type f \( -name '.env.bak*' -o -name 'auth.json.bak*' -o -name 'config.yaml.bak*' \) -mtime +"$AGE" 2>/dev/null)
log+=(".bak older than ${AGE}d: $b removed")
# 3) regenerable package caches
if [ $APPLY -eq 1 ]; then
  command -v npm >/dev/null && { npm cache clean --force >/dev/null 2>&1 || log+=("npm cache clean failed"); }
  python3 -m pip cache purge >/dev/null 2>&1 || log+=("pip cache purge failed")
  log+=("npm/pip caches cleared")
else
  log+=("would clear npm/pip caches: $(du -sh ~/.npm/_cacache ~/.cache/pip 2>/dev/null | cut -f1 | tr '\n' ' ')")
fi
echo "housekeeping [$mode]: $(IFS=';'; echo "${log[*]}")"
