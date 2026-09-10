# ─── Regentspace Build Server ───
# Optimized for Railway Hobby: 8 vCPU, 8GB RAM
#
# Layer strategy:
#   1. System deps (rarely changes)
#   2. Flutter SDK (changes per version)
#   3. Android SDK (changes per version)
#   4. App code (changes frequently)
#
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV BUILD_ID=20260910-clean-rewrite
ENV FLUTTER_HOME=/opt/flutter
ENV ANDROID_HOME=/opt/android-sdk
ENV FLUTTER_ROOT=/opt/flutter
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV GRADLE_USER_HOME=/root/.gradle
ENV PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# 8GB RAM available — 4GB JVM heap + 4GB for OS/Dart/Flutter
ENV GRADLE_OPTS="-Xmx4g -XX:MaxMetaspaceSize=1g -XX:ReservedCodeCacheSize=512m -Dfile.encoding=UTF-8"

# ─── Layer 1: System deps ───
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils zip jq \
    openjdk-21-jdk-headless \
    python3 python3-pip python3-pillow \
    && rm -rf /var/lib/apt/lists/*

# ─── Layer 2: Flutter 3.44.0 (Kotlin gradle plugin, not Groovy) ───
RUN git clone --depth 1 --branch 3.44.0 https://github.com/flutter/flutter.git "$FLUTTER_HOME" \
    && flutter precache --android \
    && flutter config --no-analytics \
    && dart --disable-analytics

# ─── Layer 3: Android SDK ───
RUN mkdir -p "$ANDROID_HOME/cmdline-tools" \
    && curl -fsSL https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o /tmp/cmdline-tools.zip \
    && unzip -q /tmp/cmdline-tools.zip -d /tmp/cmdline-tools \
    && mv /tmp/cmdline-tools/cmdline-tools "$ANDROID_HOME/cmdline-tools/latest" \
    && rm -rf /tmp/cmdline-tools.zip /tmp/cmdline-tools \
    && yes | sdkmanager --licenses > /dev/null 2>&1 || true \
    && sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

# ─── Layer 4: App setup ───
WORKDIR /app

# Server (changes rarely)
COPY server/ /app/server/
WORKDIR /app/server
RUN dart pub get

# Build script + template
COPY build.sh /app/build.sh
RUN chmod +x /app/build.sh
COPY android/ /app/android/
COPY assets/ /app/assets/
COPY lib/ /app/lib/
COPY generator/ /app/generator/
COPY analysis_options.yaml /app/analysis_options.yaml

# Generator deps
WORKDIR /app/generator
RUN dart pub get

# Pre-warm template dependencies
WORKDIR /app
RUN flutter pub get 2>&1 || true

WORKDIR /app/server

EXPOSE 8080

CMD ["dart", "run", "bin/server.dart"]
