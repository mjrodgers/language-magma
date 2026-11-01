#!/usr/bin/env bash
# Rebuild grammars/tree-sitter/tree-sitter-magma.wasm from edgarcosta/tree-sitter-magma.
#
#   scripts/build-parser.sh [commit-or-branch]
#
# Needs git and the tree-sitter CLI (0.26 or later). `tree-sitter build --wasm`
# downloads wasi-sdk on first use, so no Emscripten or Docker is required.
# Pulsar 1.127+ loads parsers with ABI 15, which this produces.
set -euo pipefail

REF="${1:-75b31f4695261967c7aa87d552d69805dc03c77b}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$HERE/grammars/tree-sitter/tree-sitter-magma.wasm"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

git clone --quiet https://github.com/edgarcosta/tree-sitter-magma.git "$WORK/tree-sitter-magma"
git -C "$WORK/tree-sitter-magma" checkout --quiet "$REF"
COMMIT="$(git -C "$WORK/tree-sitter-magma" rev-parse HEAD)"

(cd "$WORK/tree-sitter-magma" && tree-sitter build --wasm -o "$OUT" .)

# Keep the grammar file's parserSource in step with the commit we built.
sed -i.bak -E "s|(parserSource: 'github:edgarcosta/tree-sitter-magma#)[0-9a-f]+'|\1${COMMIT}'|" \
  "$HERE/grammars/modern-tree-sitter-magma.cson"
rm -f "$HERE/grammars/modern-tree-sitter-magma.cson.bak"

echo "Built $OUT from tree-sitter-magma@$COMMIT"
