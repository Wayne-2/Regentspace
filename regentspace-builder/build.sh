#!/bin/bash
#
# Regentspace Build Script
# Usage: ./build.sh <input.json> [output_dir]
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR"
GENERATOR_DIR="$SCRIPT_DIR/generator"
WORKSPACE="/tmp/regentspace-build-$$"

INPUT_JSON="${1:?Usage: build.sh <input.json> [output_dir]}"
OUTPUT_DIR="${2:-./build-output}"

echo "=== Regentspace Build ==="
echo "Input: $INPUT_JSON"
echo "Output: $OUTPUT_DIR"
echo "Workspace: $WORKSPACE"
echo ""

# [1] Validate JSON
echo "[1/10] Validating JSON..."
if ! jq empty "$INPUT_JSON" 2>/dev/null; then
    echo "ERROR: Invalid JSON input"
    exit 1
fi

# [2] Create isolated workspace
echo "[2/10] Creating workspace..."
rm -rf "$WORKSPACE"
mkdir -p "$WORKSPACE"

# [3] Copy template
echo "[3/10] Copying template..."
cp -r "$TEMPLATE_DIR/android" "$WORKSPACE/"
cp -r "$TEMPLATE_DIR/assets" "$WORKSPACE/"
cp -r "$TEMPLATE_DIR/lib" "$WORKSPACE/"
cp "$TEMPLATE_DIR/analysis_options.yaml" "$WORKSPACE/"
cp "$TEMPLATE_DIR/.metadata" "$WORKSPACE/" 2>/dev/null || true

# [4] Parse JSON and extract values
echo "[4/10] Parsing configuration..."
APP_NAME=$(jq -r '.app.name // "My App"' "$INPUT_JSON")
APP_DESC=$(jq -r '.app.description // ""' "$INPUT_JSON")
APP_VERSION=$(jq -r '.app.version // "1.0.0"' "$INPUT_JSON")
VERSION_CODE=$(jq -r '.app.versionCode // 1' "$INPUT_JSON")
PACKAGE_NAME=$(jq -r '.app.packageName // "com.example.myapp"' "$INPUT_JSON")
FCM_CHANNEL=$(jq -r '.app.fcmChannel // "default_channel"' "$INPUT_JSON")

echo "  App: $APP_NAME"
echo "  Package: $PACKAGE_NAME"
echo "  Version: $APP_VERSION ($VERSION_CODE)"

# [5] Run code generator
echo "[5/10] Running code generator..."
dart "$GENERATOR_DIR/generate.dart" "$INPUT_JSON" "$WORKSPACE"

# [6] Apply build-time configuration
echo "[6/10] Applying build configuration..."

# Replace placeholders in pubspec.yaml
sed -i "s/{{APP_NAME}}/$(echo $PACKAGE_NAME | sed 's/.*\.//')/g" "$WORKSPACE/pubspec.yaml"
sed -i "s/{{APP_DESCRIPTION}}/$APP_DESC/g" "$WORKSPACE/pubspec.yaml"
sed -i "s/{{APP_VERSION}}/$APP_VERSION/g" "$WORKSPACE/pubspec.yaml"

# Replace placeholders in AndroidManifest.xml
sed -i "s/{{APP_NAME}}/$APP_NAME/g" "$WORKSPACE/android/app/src/main/AndroidManifest.xml"
sed -i "s/{{FCM_CHANNEL}}/$FCM_CHANNEL/g" "$WORKSPACE/android/app/src/main/AndroidManifest.xml"

# Replace placeholders in build.gradle.kts
sed -i "s/{{PACKAGE_NAME}}/$PACKAGE_NAME/g" "$WORKSPACE/android/app/build.gradle.kts"
sed -i "s/{{VERSION_CODE}}/$VERSION_CODE/g" "$WORKSPACE/android/app/build.gradle.kts"
sed -i "s/{{VERSION_NAME}}/$APP_VERSION/g" "$WORKSPACE/android/app/build.gradle.kts"

# [7] Generate launcher icon from base64 (if provided)
echo "[7/10] Generating launcher icon..."
ICON_BASE64=$(jq -r '.app.iconBase64 // ""' "$INPUT_JSON")
if [ -n "$ICON_BASE64" ]; then
    echo "  Decoding app icon from build JSON..."
    ICON_TMP="$WORKSPACE/icon_input.png"
    echo "$ICON_BASE64" | base64 -d > "$ICON_TMP"

    # Use Python + Pillow to resize and overwrite mipmap icons
    python3 - "$ICON_TMP" "$WORKSPACE/android/app/src/main/res" << 'PYEOF'
import sys
from PIL import Image

icon_path = sys.argv[1]
res_dir = sys.argv[2]

# Android mipmap sizes: density -> (size, folder)
densities = {
    'mdpi':    48,
    'hdpi':    72,
    'xhdpi':   96,
    'xxhdpi':  144,
    'xxxhdpi': 192,
}

img = Image.open(icon_path).convert('RGBA')

for density, size in densities.items():
    folder = f'{res_dir}/mipmap-{density}'
    resized = img.resize((size, size), Image.LANCZOS)
    resized.save(f'{folder}/ic_launcher.png', 'PNG')
    # Also update the notification icon
    resized.save(f'{folder}/notification_display_icon.png', 'PNG')

# Also update the drawable notification icon (use xxxhdpi size)
drawable_dir = f'{res_dir}/drawable'
img_96 = img.resize((96, 96), Image.LANCZOS)
img_96.save(f'{drawable_dir}/notification_display_icon.png', 'PNG')

print(f'  Icon resized to {len(densities)} densities')
PYEOF

    rm -f "$ICON_TMP"
    echo "  Launcher icon updated"
else
    echo "  No custom icon — using default"
fi

# [8] Resolve dependencies
echo "[8/10] Resolving dependencies..."
cd "$WORKSPACE"
flutter pub get

# [9] Build APK
echo "[9/10] Building APK..."
flutter build apk --release --target-platform android-arm64 --no-tree-shake-icons --split-per-abi

# [10] Collect output
echo "[10/10] Collecting output..."
mkdir -p "$OUTPUT_DIR"
APK_PATH="$WORKSPACE/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
if [ ! -f "$APK_PATH" ]; then
    APK_PATH="$WORKSPACE/build/app/outputs/flutter-apk/app-release.apk"
fi
if [ -f "$APK_PATH" ]; then
    cp "$APK_PATH" "$OUTPUT_DIR/${PACKAGE_NAME//./_}-$APP_VERSION.apk"
    echo ""
    echo "=== Build Complete ==="
    echo "APK: $OUTPUT_DIR/${PACKAGE_NAME//./_}-$APP_VERSION.apk"
else
    echo "ERROR: APK not found at $APK_PATH"
    exit 1
fi

# Cleanup
echo "Cleaning up workspace..."
rm -rf "$WORKSPACE"

echo "Done."
