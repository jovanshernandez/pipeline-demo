#!/usr/bin/env bash
set -euo pipefail

base_url="${1:-http://localhost:8000}"

curl --fail --silent "${base_url}/health" >/dev/null
curl --fail --silent "${base_url}/ready" >/dev/null
curl --fail --silent "${base_url}/" | grep --quiet "pipeline-demo"
