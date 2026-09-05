#!/bin/bash
#
# Regentspace Docker Build Script
# Uses podman (or docker) to build an APK in an isolated container.
#
# Usage: ./docker_build.sh <input.json> [output_dir]
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT_JSON="${1:?Usage: docker_build.sh <input.json> [output_dir]}"
OUTPUT_DIR="${2:-./build-output}"

# Resolve input to absolute path
INPUT_JSON="$(cd "$(dirname "$INPUT_JSON")" && pwd)/$(basename "$INPUT_JSON")"

# Prefer podman, fall back to docker
if command -v podman &>/dev/null; then
    CONTAINER_RUN="podman"
elif command -v docker &>/dev/null; then
    CONTAINER_RUN="docker"
else
    echo "ERROR: Neither podman nor docker found. Install one to proceed."
    exit 1
fi

IMAGE_NAME="regentspace-builder"
CONTAINER_NAME="regentspace-build-$$"

echo "=== Regentspace Docker Build ==="
echo "Runtime:  $CONTAINER_RUN"
echo "Image:    $IMAGE_NAME"
echo "Input:    $INPUT_JSON"
echo "Output:   $OUTPUT_DIR"
echo ""

# [1] Build image (if not cached)
echo "[1/3] Building container image..."
$CONTAINER_RUN build -t "$IMAGE_NAME" "$SCRIPT_DIR"

# [2] Run build
echo "[2/3] Running build in container..."
mkdir -p "$OUTPUT_DIR"
$CONTAINER_RUN run --rm \
    --name "$CONTAINER_NAME" \
    -v "$INPUT_JSON:/input/build.json:ro" \
    -v "$(realpath "$OUTPUT_DIR"):/output" \
    "$IMAGE_NAME" \
    /input/build.json /output

# [3] Done
echo ""
echo "[3/3] Done."
echo "APK output: $OUTPUT_DIR/"
ls -lh "$OUTPUT_DIR"/*.apk 2>/dev/null || echo "(no APK found)"
