#!/bin/bash
set -euo pipefail

INPUT_JSON="${1:?Usage: docker_build_entrypoint.sh <input.json>}"
OUTPUT_DIR="${2:-/output}"

echo "=== Regentspace Docker Build ==="
echo "Input: $INPUT_JSON"

# Create workspace
WORKSPACE="/tmp/build-workspace"
rm -rf "$WORKSPACE"
mkdir -p "$WORKSPACE"

# [1] Copy template
echo "[1/8] Copying template..."
cp -r /app/template/android "$WORKSPACE/"
cp -r /app/template/assets "$WORKSPACE/"
cp -r /app/template/lib "$WORKSPACE/"
cp -r /app/template/generator "$WORKSPACE/"
cp /app/template/analysis_options.yaml "$WORKSPACE/"
cp /app/template/pubspec.yaml "$WORKSPACE/"
cp /app/template/.metadata "$WORKSPACE/" 2>/dev/null || true

# [2] Parse JSON
echo "[2/8] Parsing JSON..."
APP_NAME=$(jq -r '.app.name // "My App"' "$INPUT_JSON")
PACKAGE_NAME=$(jq -r '.app.packageName // "com.example.myapp"' "$INPUT_JSON")
APP_VERSION=$(jq -r '.app.version // "1.0.0"' "$INPUT_JSON")
VERSION_CODE=$(jq -r '.app.versionCode // 1' "$INPUT_JSON")
FCM_CHANNEL=$(jq -r '.app.fcmChannel // "default_channel"' "$INPUT_JSON")
APP_DESC=$(jq -r '.app.description // ""' "$INPUT_JSON")

echo "  App: $APP_NAME"
echo "  Package: $PACKAGE_NAME"
echo "  Version: $APP_VERSION ($VERSION_CODE)"

# [3] Run code generator
echo "[3/8] Running code generator..."
cd "$WORKSPACE"
dart run generator/generate.dart "$INPUT_JSON" "$WORKSPACE"

# [4] Apply placeholders
echo "[4/8] Applying build configuration..."
sed -i "s/{{APP_NAME}}/$(echo $PACKAGE_NAME | sed 's/.*\.//')/g" "$WORKSPACE/pubspec.yaml"
sed -i "s/{{APP_DESC}}/$APP_DESC/g" "$WORKSPACE/pubspec.yaml"
sed -i "s/{{APP_VERSION}}/$APP_VERSION/g" "$WORKSPACE/pubspec.yaml"
sed -i "s/{{APP_NAME}}/$APP_NAME/g" "$WORKSPACE/android/app/src/main/AndroidManifest.xml"
sed -i "s/{{FCM_CHANNEL}}/$FCM_CHANNEL/g" "$WORKSPACE/android/app/src/main/AndroidManifest.xml"
sed -i "s/{{PACKAGE_NAME}}/$PACKAGE_NAME/g" "$WORKSPACE/android/app/build.gradle.kts"
sed -i "s/{{VERSION_CODE}}/$VERSION_CODE/g" "$WORKSPACE/android/app/build.gradle.kts"
sed -i "s/{{VERSION_NAME}}/$APP_VERSION/g" "$WORKSPACE/android/app/build.gradle.kts"

# [5] Pub get
echo "[5/8] Resolving dependencies..."
cd "$WORKSPACE"
flutter pub get

# [6] Build APK
echo "[6/8] Building APK (this may take a while)..."
cd "$WORKSPACE"
flutter build apk --release

# [7] Collect output
echo "[7/8] Collecting output..."
mkdir -p "$OUTPUT_DIR"
APK_PATH="$WORKSPACE/build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK_PATH" ]; then
    APK_NAME="${PACKAGE_NAME//./_}-$APP_VERSION.apk"
    cp "$APK_PATH" "$OUTPUT_DIR/$APK_NAME"
    echo ""
    echo "=== Build Complete ==="
    echo "APK: $OUTPUT_DIR/$APK_NAME"
    ls -lh "$OUTPUT_DIR/$APK_NAME"
else
    echo "ERROR: APK not found at $APK_PATH"
    find "$WORKSPACE/build" -name "*.apk" 2>/dev/null
    exit 1
fi

# [8] Cleanup
echo "[8/8] Cleaning up..."
rm -rf "$WORKSPACE"

echo "Done."
