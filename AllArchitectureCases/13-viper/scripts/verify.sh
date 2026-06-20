#!/usr/bin/env bash
set -euo pipefail

readonly PROJECT="VIPERArchitectureCase.xcodeproj"
readonly SCHEME="VIPERArchitectureCase"
readonly BUILD_DESTINATION="generic/platform=iOS Simulator"
readonly TEST_DESTINATION="${VIPER_CASE_TEST_DESTINATION:-platform=iOS Simulator,name=Any iOS Simulator Device}"
readonly CASE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
readonly DERIVED_DATA_PATH="${VIPER_CASE_DERIVED_DATA_PATH:-${CASE_ROOT}/.xcode-derived-data/VIPERArchitectureCase}"
readonly CLONED_PACKAGES_PATH="${VIPER_CASE_XCODE_PACKAGE_CACHE:-${CASE_ROOT}/.xcode-package-cache/VIPERArchitectureCase}"
readonly RESULT_BUNDLE_ROOT="${VIPER_CASE_RESULT_BUNDLE_PATH:-${CASE_ROOT}/.xcode-result-bundles/VIPERArchitectureCase}"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/verify.sh <list|build|test>
USAGE
}

run_list() {
  xcodebuild -list -project "${PROJECT}" -scheme "${SCHEME}" -derivedDataPath "${DERIVED_DATA_PATH}" -clonedSourcePackagesDirPath "${CLONED_PACKAGES_PATH}"
}

run_build() {
  xcodebuild -project "${PROJECT}" -scheme "${SCHEME}" -configuration Debug -destination "${BUILD_DESTINATION}" -derivedDataPath "${DERIVED_DATA_PATH}" -clonedSourcePackagesDirPath "${CLONED_PACKAGES_PATH}" CODE_SIGNING_ALLOWED=NO build
}

run_test() {
  local result_bundle_path="${RESULT_BUNDLE_ROOT}/unit.xcresult"
  rm -rf "${result_bundle_path}"
  mkdir -p "${RESULT_BUNDLE_ROOT}"
  xcodebuild -project "${PROJECT}" -scheme "${SCHEME}" -configuration Debug -destination "${TEST_DESTINATION}" -derivedDataPath "${DERIVED_DATA_PATH}" -clonedSourcePackagesDirPath "${CLONED_PACKAGES_PATH}" -resultBundlePath "${result_bundle_path}" CODE_SIGNING_ALLOWED=NO test
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

case "$1" in
  list) run_list ;;
  build) run_build ;;
  test) run_test ;;
  *) usage; exit 1 ;;
esac
