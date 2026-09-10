#!/bin/bash
#
# Regentspace APK Build Script
# Usage: ./build.sh <input.json> <output_dir>
#
# Environment:
#   FLUTTER_ROOT  — Flutter SDK path (default: /opt/flutter)
#   ANDROID_HOME  — Android SDK path (default: /opt/android-sdk)
#   GRADLE_USER_HOME — Gradle cache (default: /root/.gradle)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR"
GENERATOR_DIR="$SCRIPT_DIR/generator"
WORKSPACE="/tmp/regentspace-build-$$"

INPUT_JSON="${1:?Usage: build.sh <input.json> <output_dir>}"
OUTPUT_DIR="${2:?Usage: build.sh <input.json> <output_dir>}"

# Ensure required env vars
export FLUTTER_ROOT="${FLUTTER_ROOT:-/opt/flutter}"
export ANDROID_HOME="${ANDROID_HOME:-/opt/android-sdk}"
export GRADLE_USER_HOME="${GRADLE_USER_HOME:-/root/.gradle}"
export PATH="$FLUTTER_ROOT/bin:$FLUTTER_ROOT/bin/cache/dart-sdk/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

echo "=== Regentspace APK Build ==="
echo "Flutter: $(flutter --version 2>&1 | head -1)"
echo "Java: $(java -version 2>&1 | head -1)"
echo ""

# ── [1] Validate JSON ──
echo "[1/8] Validating input..."
if ! jq empty "$INPUT_JSON" 2>/dev/null; then
  echo "ERROR: Invalid JSON input"
  exit 1
fi

APP_NAME=$(jq -r '.app.name // "App"' "$INPUT_JSON")
APP_VERSION=$(jq -r '.app.version // "1.0.0"' "$INPUT_JSON")
VERSION_CODE=$(jq -r '.app.versionCode // 1' "$INPUT_JSON")
PACKAGE_NAME=$(jq -r '.app.packageName // "com.example.app"' "$INPUT_JSON")
FCM_CHANNEL=$(jq -r '.app.fcmChannel // "default_channel"' "$INPUT_JSON")
echo "  App: $APP_NAME ($PACKAGE_NAME) v$APP_VERSION"

# ── [2] Create workspace ──
echo "[2/8] Setting up workspace..."
rm -rf "$WORKSPACE"
mkdir -p "$WORKSPACE"

# ── [3] Copy template ──
echo "[3/8] Copying template..."
cp -r "$TEMPLATE_DIR/android" "$WORKSPACE/"
cp -r "$TEMPLATE_DIR/assets" "$WORKSPACE/"
cp -r "$TEMPLATE_DIR/lib" "$WORKSPACE/"
cp "$TEMPLATE_DIR/analysis_options.yaml" "$WORKSPACE/"
cp "$TEMPLATE_DIR/.metadata" "$WORKSPACE/" 2>/dev/null || true

# ── [4] Generate code from JSON ──
echo "[4/8] Running code generator..."
dart "$GENERATOR_DIR/generate.dart" "$INPUT_JSON" "$WORKSPACE"

# ── [5] Apply config ──
echo "[5/8] Applying build config..."
APP_NAME_ESCAPED=$(echo "$APP_NAME" | sed 's/[&/\]/\\&/g')
sed -i "s/{{APP_NAME}}/$APP_NAME_ESCAPED/g" "$WORKSPACE/android/app/src/main/AndroidManifest.xml"
sed -i "s/{{FCM_CHANNEL}}/$FCM_CHANNEL/g" "$WORKSPACE/android/app/src/main/AndroidManifest.xml"
sed -i "s/{{PACKAGE_NAME}}/$PACKAGE_NAME/g" "$WORKSPACE/android/app/build.gradle.kts"
sed -i "s/{{VERSION_CODE}}/$VERSION_CODE/g" "$WORKSPACE/android/app/build.gradle.kts"
sed -i "s/{{VERSION_NAME}}/$APP_VERSION/g" "$WORKSPACE/android/app/build.gradle.kts"

# ── [6] Generate icon (if provided) ──
echo "[6/8] Processing icon..."
ICON_BASE64=$(jq -r '.app.iconBase64 // ""' "$INPUT_JSON")
if [ -n "$ICON_BASE64" ]; then
  ICON_TMP="$WORKSPACE/icon_input.png"
  echo "$ICON_BASE64" | base64 -d > "$ICON_TMP"
  python3 - "$ICON_TMP" "$WORKSPACE/android/app/src/main/res" << 'PYEOF'
import sys
from PIL import Image

icon_path = sys.argv[1]
res_dir = sys.argv[2]
densities = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}
img = Image.open(icon_path).convert('RGBA')
for density, size in densities.items():
    resized = img.resize((size, size), Image.LANCZOS)
    resized.save(f'{res_dir}/mipmap-{density}/ic_launcher.png', 'PNG')
    resized.save(f'{res_dir}/mipmap-{density}/notification_display_icon.png', 'PNG')
drawable_dir = f'{res_dir}/drawable'
img.resize((96, 96), Image.LANCZOS).save(f'{drawable_dir}/notification_display_icon.png', 'PNG')
print(f'  Icon resized to {len(densities)} densities')
PYEOF
  rm -f "$ICON_TMP"
else
  echo "  Using default icon"
fi

# ── [7] Resolve dependencies ──
echo "[7/8] Resolving dependencies..."
cd "$WORKSPACE"
flutter pub get 2>&1 | grep -vE "^(FINE|IO|SLVR|DBG|ERR|WARN|  )" || true

# ── [8] Build APK ──
echo "[8/8] Building APK (this takes a few minutes)..."
flutter build apk --release --target-platform android-arm64 --no-tree-shake-icons --split-per-abi 2>&1 | grep -vE "^(FINE|IO|SLVR|DBG)" || true

# ── Collect output ──
echo ""
echo "Collecting APK..."
mkdir -p "$OUTPUT_DIR"
APK_PATH="$WORKSPACE/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
if [ ! -f "$APK_PATH" ]; then
  APK_PATH="$WORKSPACE/build/app/outputs/flutter-apk/app-release.apk"
fi

if [ -f "$APK_PATH" ]; then
  APK_OUT="$OUTPUT_DIR/${PACKAGE_NAME//./_}-$APP_VERSION.apk"
  cp "$APK_PATH" "$APK_OUT"
  APK_SIZE=$(du -h "$APK_OUT" | cut -f1)
  echo "=== Build Complete ==="
  echo "APK: $APK_OUT ($APK_SIZE)"
else
  echo "ERROR: APK not found at $APK_PATH"
  ls -la "$WORKSPACE/build/app/outputs/flutter-apk/" 2>/dev/null || echo "  (directory does not exist)"
  exit 1
fi

# Cleanup
rm -rf "$WORKSPACE"
echo "Done."
