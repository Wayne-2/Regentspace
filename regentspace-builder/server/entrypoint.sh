#!/bin/bash
set -e

# Activate swap file
swapon /swapfile 2>/dev/null || true

# Start the build server
exec dart run bin/server.dart
