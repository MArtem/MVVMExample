#!/usr/bin/env bash
set -euo pipefail

readonly PROJECT="MVVMExample.xcodeproj"
readonly SCHEME="MVVMExample"
readonly DESTINATION_IOS_26="platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/verify.sh <list|build>

Levels:
  list   Verify Xcode project structure
  build  Build MVVMExample on iPhone 17 Pro (iOS 26.0)
EOF
}

run_list() {
  xcodebuild -list -project "${PROJECT}"
}

run_build() {
  xcodebuild \
    -project "${PROJECT}" \
    -scheme "${SCHEME}" \
    -configuration Debug \
    -destination "${DESTINATION_IOS_26}" \
    CODE_SIGNING_ALLOWED=NO \
    build
}

main() {
  if [[ $# -ne 1 ]]; then
    usage
    exit 1
  fi

  case "$1" in
    list)
      run_list
      ;;
    build)
      run_build
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
