#!/bin/bash
# Sync authored school JSON into the app bundle resources.
# Source of truth: content/schools/*.json  →  MorningReset/Resources/Schools/
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/MorningReset/Resources/Schools"
cp "$ROOT"/content/schools/*.json "$ROOT/MorningReset/Resources/Schools/" 2>/dev/null || true
ls -1 "$ROOT/MorningReset/Resources/Schools/" | wc -l | xargs echo "synced school files:"
