#!/usr/bin/env bash
# Scan the chart with trivy. Subcharts cannot be skipped, helm needs them to
# render, so their findings are filtered out of the json instead.
set -euo pipefail
cd "$(dirname "$0")/.."

# pinned so a new rule upstream does not turn someone else's PR red
bundle=mirror.gcr.io/aquasec/trivy-checks@sha256:1583562f8b90ed2a071b99f0e5ffff6b57e4ceb6ca3e4796577b4e6a339eb74c

# cache per digest, or trivy reuses whatever bundle it already has
cache="${XDG_CACHE_HOME:-$HOME/.cache}/vre-trivy/${bundle##*:}"

json=$(mktemp)
log=$(mktemp)
trap 'rm -f "$json" "$log"' EXIT

if ! trivy config --format json --cache-dir "$cache" \
	--checks-bundle-repository "$bundle" \
	--helm-values vre/linter_values.yaml vre >"$json" 2>"$log"; then
	cat "$log" >&2
	exit 1
fi

# without this trivy quietly uses the checks built into the binary
if grep -q "Falling back to embedded checks" "$log"; then
	cat "$log" >&2
	echo "scan.sh: could not fetch the pinned checks bundle" >&2
	exit 1
fi

python3 -c '
import json, sys

results = [r for r in json.load(sys.stdin).get("Results") or []
           if not r["Target"].startswith("charts/")]

# nothing scanned means the chart did not render
if not results:
    sys.exit("scan.sh: trivy scanned no templates, is the chart rendering?")

found = [r["Target"] + ":" + str(m.get("CauseMetadata", {}).get("StartLine", 0))
         + "\t" + m["Severity"] + "\t" + m["ID"] + "\t" + m["Title"]
         for r in results for m in r.get("Misconfigurations") or []]

if found:
    print("\n".join(found))
    sys.exit(1)
' <"$json"
