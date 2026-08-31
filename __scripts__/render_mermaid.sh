#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <input.mmd> [svg|png|pdf] [output-file]" >&2
  exit 1
fi

INPUT_FILE="$1"
OUTPUT_FORMAT="${2:-svg}"
OUTPUT_FILE="${3:-}"

if [ ! -f "$INPUT_FILE" ]; then
  echo "Input file not found: $INPUT_FILE" >&2
  exit 1
fi

case "$OUTPUT_FORMAT" in
  svg|png|pdf) ;;
  *)
    echo "Unsupported format: $OUTPUT_FORMAT (use: svg, png, or pdf)" >&2
    exit 1
    ;;
esac

if [ -z "$OUTPUT_FILE" ]; then
  OUTPUT_FILE="${INPUT_FILE%.*}.${OUTPUT_FORMAT}"
fi

MMDC_BIN=""
if command -v mmdc >/dev/null 2>&1; then
  MMDC_BIN="mmdc"
elif [ -x "$HOME/.local/share/mise/shims/mmdc" ]; then
  MMDC_BIN="$HOME/.local/share/mise/shims/mmdc"
elif [ -x "$HOME/.local/bin/mmdc" ]; then
  MMDC_BIN="$HOME/.local/bin/mmdc"
fi

if [ -z "$MMDC_BIN" ]; then
  echo "Mermaid CLI (mmdc) not found." >&2
  echo "Install with: mise use -g npm:@mermaid-js/mermaid-cli@latest" >&2
  exit 1
fi

"$MMDC_BIN" -i "$INPUT_FILE" -o "$OUTPUT_FILE" -t dark -b transparent

echo "Rendered Mermaid: $INPUT_FILE -> $OUTPUT_FILE"
