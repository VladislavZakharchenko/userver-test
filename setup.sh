#!/usr/bin/env bash
set -euo pipefail

IMG=ghcr.io/userver-framework/ubuntu-22.04-userver
DIGEST=sha256:fca9c8ac7e97b4e2b042d822facbb152aec10a9d4e09c0862e44c50640f3f303

LIMITS=(--cpus=4 --cpuset-cpus=0-3 --memory=8g --memory-swap=8g)

docker run --rm -it \
    "${LIMITS[@]}" \
    -v "$PWD:/work" \
    -w /work \
    "$IMG@$DIGEST" \
    bash -ec '
        apt-get update
        apt-get install -y clang git make g++ ca-certificates time

        git clone https://github.com/aras-p/ClangBuildAnalyzer.git \
            /tmp/ClangBuildAnalyzer

        cd /tmp/ClangBuildAnalyzer
        make -f projects/make/Makefile -j4
        cp build/ClangBuildAnalyzer /usr/local/bin/

        cd /work
        exec bash -i
    '