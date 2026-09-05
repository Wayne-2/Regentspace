# ─── Stage 1: Flutter build environment ───
FROM ubuntu:24.04 AS flutter-env

ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_HOME=/opt/flutter
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils zip \
    openjdk-17-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Install Flutter
RUN git clone --depth 1 --branch 3.27.4 https://github.com/flutter/flutter.git "$FLUTTER_HOME" \
    && flutter precache --android \
    && flutter config --no-analytics \
    && dart --disable-analytics

# Accept Android SDK licenses
RUN mkdir -p "$ANDROID_HOME/cmdline-tools" \
    && curl -fsSL https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o /tmp/cmdline-tools.zip \
    && unzip -q /tmp/cmdline-tools.zip -d /tmp/cmdline-tools \
    && mv /tmp/cmdline-tools/cmdline-tools "$ANDROID_HOME/cmdline-tools/latest" \
    && rm -rf /tmp/cmdline-tools.zip /tmp/cmdline-tools \
    && yes | sdkmanager --licenses > /dev/null 2>&1 || true \
    && sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

# ─── Stage 2: Build ───
FROM flutter-env AS builder

WORKDIR /app

# Copy template
COPY . /app/template/

# Copy generator
COPY generator/ /app/template/generator/

# Input JSON will be mounted at /input/build.json
# Output APK will be placed at /output/

# Build entrypoint
COPY docker_build_entrypoint.sh /app/docker_build_entrypoint.sh
RUN chmod +x /app/docker_build_entrypoint.sh

ENTRYPOINT ["/app/docker_build_entrypoint.sh"]
