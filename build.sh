#!/bin/bash
set -e

# Clone Flutter stable if not present
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

export PATH="$PATH:`pwd`/flutter/bin"

# Verify Flutter installation
flutter --version

# Enable web & fetch dependencies
flutter config --enable-web
flutter pub get

# Generate .env file from Vercel environment variables
echo "GEMINI_API_KEY=$GEMINI_API_KEY" > .env

# Build the release web package
flutter build web --release