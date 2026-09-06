#!/bin/bash
# Monitor build server activity
BUILDS_DIR="/home/wayne/Documents/regentspace/regentspace-builder/builds"

echo "=== Build Server Monitor ==="
echo "Watching: $BUILDS_DIR"
echo "Press Ctrl+C to stop"
echo ""

while true; do
  clear
  echo "=== $(date '+%H:%M:%S') ==="
  echo ""
  
  # Show builds
  if [ -d "$BUILDS_DIR" ]; then
    for dir in "$BUILDS_DIR"/*/; do
      [ -d "$dir" ] || continue
      build_id=$(basename "$dir")
      apk=$(find "$dir" -name "*.apk" 2>/dev/null | head -1)
      if [ -n "$apk" ]; then
        size=$(du -h "$apk" | cut -f1)
        echo "✅ $build_id — APK: $(basename "$apk") ($size)"
      else
        files=$(find "$dir" -type f 2>/dev/null | wc -l)
        echo "🔨 $build_id — building... ($files files)"
      fi
    done
  fi
  
  # Health check
  status=$(curl -s http://localhost:8080/health 2>/dev/null)
  if [ -z "$status" ]; then
    echo ""
    echo "⚠️  Server NOT responding"
  fi
  
  echo ""
  sleep 3
done
