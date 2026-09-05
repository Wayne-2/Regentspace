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

# [7] Add user assets (if provided)
echo "[7/10] Checking for user assets..."
ICON_PATH=$(jq -r '.app.iconPath // ""' "$INPUT_JSON")
if [ -n "$ICON_PATH" ] && [ -f "$ICON_PATH" ]; then
    echo "  Found app icon: $ICON_PATH"
    # Copy icon to mipmap directories (would need image processing)
fi

# [8] Resolve dependencies
echo "[8/10] Resolving dependencies..."
cd "$WORKSPACE"
flutter pub get

# [9] Build APK
echo "[9/10] Building APK..."
flutter build apk --release

# [10] Collect output
echo "[10/10] Collecting output..."
mkdir -p "$OUTPUT_DIR"
APK_PATH="$WORKSPACE/build/app/outputs/flutter-apk/app-release.apk"
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
