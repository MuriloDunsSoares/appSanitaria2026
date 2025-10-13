#!/usr/bin/env bash
set -euo pipefail

echo "== Flutter & Dart versions =="
flutter --version || true
dart --version || true

echo "== Clean & get packages =="
flutter clean
flutter pub get

echo "== Static analysis =="
flutter analyze || true

echo "== Dart Code Metrics (project) =="
dart run dart_code_metrics:metrics analyze lib --reporter=github || true
dart run dart_code_metrics:metrics check-unused-files lib || true

echo "== Format & autofix (safe) =="
dart format .
dart fix --apply || true

echo "== Tests =="
dart test --reporter=expanded || true

echo "== Build size (APK) =="
flutter build apk --analyze-size || true

echo "== Done =="





