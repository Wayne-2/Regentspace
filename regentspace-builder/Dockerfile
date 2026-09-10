# ─── Regentspace Build Server ───
# Railway Hobby: 8 vCPU, 8GB RAM, 100GB disk
FROM ubuntu:24.04 AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV BUILD_ID=20260910-optimized-flutter3440
ENV FLUTTER_HOME=/opt/flutter
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# ─── Layer 1: System deps (rarely changes) ───
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils zip jq \
    openjdk-21-jdk-headless \
    python3 python3-pip python3-pillow \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

# 8GB RAM available — 4GB JVM heap leaves 4GB for OS + Dart
ENV GRADLE_OPTS="-Xmx4g -XX:MaxMetaspaceSize=1g -XX:ReservedCodeCacheSize=512m -Dfile.encoding=UTF-8"
ENV JAVA_OPTS="-Xmx4g -XX:MaxMetaspaceSize=1g"

# ─── Layer 2: Flutter SDK (cached unless branch changes) ───
RUN git clone --depth 1 --branch 3.44.0 https://github.com/flutter/flutter.git "$FLUTTER_HOME" \
    && flutter precache --android \
    && flutter config --no-analytics \
    && dart --disable-analytics

# ─── Layer 3: Android SDK (cached unless versions change) ───
RUN mkdir -p "$ANDROID_HOME/cmdline-tools" \
    && curl -fsSL https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o /tmp/cmdline-tools.zip \
    && unzip -q /tmp/cmdline-tools.zip -d /tmp/cmdline-tools \
    && mv /tmp/cmdline-tools/cmdline-tools "$ANDROID_HOME/cmdline-tools/latest" \
    && rm -rf /tmp/cmdline-tools.zip /tmp/cmdline-tools \
    && yes | sdkmanager --licenses > /dev/null 2>&1 || true \
    && sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

# ─── Layer 4: Pre-cache Gradle wrapper + dependencies ───
# Download Gradle 9.1.0 wrapper now so builds don't re-download
RUN mkdir -p /opt/gradle \
    && curl -fsSL https://services.gradle.org/distributions/gradle-9.1.0-bin.zip -o /tmp/gradle.zip \
    && unzip -q /tmp/gradle.zip -d /opt/gradle \
    && rm /tmp/gradle.zip \
    && export GRADLE_USER_HOME=/root/.gradle \
    && mkdir -p "$GRADLE_USER_HOME/wrapper/dists" \
    && mkdir -p "$GRADLE_USER_HOME/caches"

# ─── Layer 5: Flutter doctor (warms up all Flutter caches) ───
RUN flutter doctor -v

# ─── App setup ───
WORKDIR /app

# Copy server first (rarely changes)
COPY server/ /app/server/
WORKDIR /app/server
RUN dart pub get

# Copy template files
COPY build.sh /app/build.sh
RUN chmod +x /app/build.sh
COPY android/ /app/android/
COPY assets/ /app/assets/
COPY lib/ /app/lib/
COPY generator/ /app/generator/
COPY analysis_options.yaml /app/analysis_options.yaml

# Install generator deps
WORKDIR /app/generator
RUN dart pub get

# Pre-install template dependencies (cached layer)
# This means flutter pub get in build.sh only resolves the generated pubspec
WORKDIR /app
RUN flutter pub get || true

WORKDIR /app/server

EXPOSE 8080

CMD ["dart", "run", "bin/server.dart"]
