#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$ROOT/results"
mkdir -p "$OUT"

MODE="${1:-all}"

if [[ "$MODE" == "all" ]]; then
    VERSIONS=(baseline optimized)
else
    VERSIONS=("$MODE")
fi

for VERSION in "${VERSIONS[@]}"; do
    SRC="$ROOT/$VERSION"
    BUILD="$SRC/build-trace-release"
    LOG="$OUT/$VERSION-build.log"

    # Clean
    rm -rf "$BUILD"
    rm -f "$OUT/$VERSION.bin" "$OUT/$VERSION.txt"

    # Configure
    cmake \
    -S "$SRC" -B "$BUILD" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_CXX_FLAGS=-ftime-trace \
    -DUSERVER_USE_CCACHE=OFF \
    -DUSERVER_SANITIZE:STRING= \
    > "$LOG" 2>&1

    # Profile
    ClangBuildAnalyzer --start "$BUILD" >> "$LOG" 2>&1

    /usr/bin/time -p -o "$OUT/$VERSION-timing.txt" \
        cmake --build "$BUILD" -j4 --target myservice \
        >> "$LOG" 2>&1

    ClangBuildAnalyzer --stop "$BUILD" "$OUT/$VERSION.bin" \
        >> "$LOG" 2>&1

    ClangBuildAnalyzer --analyze "$OUT/$VERSION.bin" \
        2>> "$LOG" | tee "$OUT/$VERSION.txt"
done