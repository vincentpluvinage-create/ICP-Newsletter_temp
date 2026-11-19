#!/bin/bash
# Sonicourt raw-data audit for the Mac. Read-only. Run from any folder:
#   bash mac-raw-data-audit.sh
# Prints, for every session folder found under the two project roots, the
# counts and sizes of the raw file kinds the analysis tools and reports need.

ROOTS=(
  "$HOME/Desktop/CLAUDE Menlo Circus Club Projects/PBAI Commercial Phase/TESTING"
  "$HOME/Desktop/CLAUDE Menlo Circus Club Projects/CLUB77-Product/PBAI-Native-App/SonicourtServeTest/TESTING"
)
EXPECTED=(
  club-2026-08-07 driveway-2026-08-09 club-2026-08-10 club-2026-08-11 club-2026-08-12
  club-2026-08-16 club-2026-08-18 club-2026-08-24 driveway-2026-09-27 driveway-2026-10-11
  driveway-2026-10-12 club-2026-10-15 driveway-2026-10-26 driveway-2026-10-28
  driveway-2026-10-31 driveway-2026-11-01 club-2026-11-01 club-2026-11-02 driveway-2026-11-05
  driveway-2026-11-06 driveway-2026-11-07 driveway-2026-11-08 driveway-2026-11-09
  driveway-2026-11-10 driveway-2026-11-11 driveway-2026-11-13 driveway-2026-11-15
  court-2026-11-16
)

count() { find "$1" -type f -name "$2" 2>/dev/null | wc -l | tr -d ' '; }
size()  { find "$1" -type f -name "$2" -exec stat -f %z {} + 2>/dev/null | awk '{s+=$1} END {printf "%.1f", s/1048576}'; }

for root in "${ROOTS[@]}"; do
  echo "=================================================================="
  echo "ROOT: $root"
  if [ ! -d "$root" ]; then echo "  MISSING"; continue; fi
  echo "  total: $(du -sh "$root" 2>/dev/null | cut -f1)"
  printf "  %-46s %6s %7s %6s %6s %6s %6s %6s %6s\n" folder caf MB_caf impct blocks pad clips jpg wrist
  for d in "$root"/*/; do
    n=$(basename "$d")
    printf "  %-46s %6s %7s %6s %6s %6s %6s %6s %6s\n" "$n" \
      "$(count "$d" '*.caf')" "$(size "$d" '*.caf')" \
      "$(count "$d" '*impacts.jsonl')" "$(count "$d" '*blocks.csv')" \
      "$(count "$d" 'pad-calls*.log')" "$(count "$d" '*clip.mov')" \
      "$(count "$d" '*.jpg')" "$(count "$d" '*wrist*.jsonl')"
  done
done

echo "=================================================================="
echo "Expected session folders not found under either root (by date prefix):"
for e in "${EXPECTED[@]}"; do
  found=0
  for root in "${ROOTS[@]}"; do
    ls -d "$root"/"$e"* >/dev/null 2>&1 && found=1
  done
  [ $found -eq 0 ] && echo "  $e"
done
echo
echo "iPad day folders still on the iPad are not covered: check Files > On My iPad > Sonicourt."
