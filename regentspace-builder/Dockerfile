# ─── Cloud Run Dockerfile for Regentspace Build Server ───
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_HOME=/opt/flutter
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils zip jq \
    openjdk-17-jdk-headless \
    python3 python3-pip python3-pillow \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Install Flutter
RUN git clone --depth 1 --branch 3.27.4 https://github.com/flutter/flutter.git "$FLUTTER_HOME" \
    && flutter precache --android \
    && flutter config --no-analytics \
    && dart --disable-analytics

# Accept Android SDK licenses and install
RUN mkdir -p "$ANDROID_HOME/cmdline-tools" \
    && curl -fsSL https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o /tmp/cmdline-tools.zip \
    && unzip -q /tmp/cmdline-tools.zip -d /tmp/cmdline-tools \
    && mv /tmp/cmdline-tools/cmdline-tools "$ANDROID_HOME/cmdline-tools/latest" \
    && rm -rf /tmp/cmdline-tools.zip /tmp/cmdline-tools \
    && yes | sdkmanager --licenses > /dev/null 2>&1 || true \
    && sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

# Pre-cache flutter deps
RUN flutter doctor -v

# ─── App setup ───
WORKDIR /app

# Copy server first (for caching)
COPY server/ /app/server/

# Install server deps
WORKDIR /app/server
RUN dart pub get

# Copy template files directly to /app/ (build.sh uses SCRIPT_DIR as template root)
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

# Pre-install template deps (cached layer)
WORKDIR /app
RUN flutter pub get || true

WORKDIR /app/server

EXPOSE 8080

CMD ["dart", "run", "bin/server.dart"]
