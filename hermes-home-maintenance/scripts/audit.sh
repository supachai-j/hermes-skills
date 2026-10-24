#!/usr/bin/env bash
# Read-only audit of a Hermes home. Never opens .env / auth.json / secrets contents.
# Usage: audit.sh            (HERMES_HOME defaults to ~/.hermes)
set -uo pipefail
H="${HERMES_HOME:-$HOME/.hermes}"
[ -d "$H" ] || { echo "no Hermes home at $H"; exit 1; }
echo "== Hermes home: $H"
echo "-- total / top 12 by size"
du -sh "$H" 2>/dev/null | cut -f1
du -sh "$H"/* "$H"/.[!.]* 2>/dev/null | sort -h -r | head -12
echo "-- disk (this filesystem)"
df -h "$H" | tail -1
echo "-- quick snapshots (count per label)"
if [ -d "$H/state-snapshots" ]; then
  ls -1 "$H/state-snapshots" | sed -E 's/^[0-9]{8}-[0-9]{6}-?//' | sort | uniq -c
  du -sh "$H/state-snapshots" | cut -f1
else echo "none"; fi
echo "-- per-profile snapshots / state.db"
for p in "$H"/profiles/*/; do
  [ -d "$p" ] || continue
  n=$(ls -1 "$p/state-snapshots" 2>/dev/null | wc -l)
  db=$(du -sh "$p/state.db" 2>/dev/null | cut -f1)
  echo "$(basename "$p"): snapshots=$n state.db=${db:-none}"
done
echo "-- hand-made .bak files (credentials may remain in them): count, oldest age in days"
now=$(date +%s)
find "$H" "$H"/profiles/* -maxdepth 1 -type f \( -name '.env.bak*' -o -name 'auth.json.bak*' -o -name 'config.yaml.bak*' \) -printf '%T@ %p\n' 2>/dev/null \
 | awk -v now="$now" 'NR==1{o=$1} {c++; if($1<o)o=$1} END{ if(c) printf "%d files, oldest %d days\n", c, (now-o)/86400; else print "0 files"}'
echo "-- external caches (not Hermes-managed)"
du -sh ~/.npm/_cacache ~/.cache/pip ~/.cache/huggingface 2>/dev/null
echo "-- session retention setting (config.yaml, key names only)"
grep -n -A4 -E '^sessions:' "$H/config.yaml" 2>/dev/null | grep -E 'sessions:|auto_prune|retention_days' || echo "no sessions: block -> documented defaults apply (auto_prune on, 90 days); verify in your version's docs"
echo "-- off-machine backup / housekeeping jobs (cron names)"
hermes cron list 2>/dev/null | grep -i -E 'backup|housekeep|restore' || echo "none found by name"
