#!/usr/bin/env bash
set -euo pipefail

readonly PROJECT="VIPCleanSwiftCase.xcodeproj"
readonly SCHEME="VIPCleanSwiftCase"
readonly UNIT_TEST_PLAN="VIPCleanSwiftCase"
readonly UI_TEST_PLAN="VIPCleanSwiftCaseUI"
readonly DESTINATION_IOS_26="platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0"
readonly CASE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
readonly DERIVED_DATA_PATH="${VIPCLEANSWIFTCASE_DERIVED_DATA_PATH:-${CASE_ROOT}/.xcode-derived-data/VIPCleanSwiftCase}"
readonly CLONED_PACKAGES_PATH="${VIPCLEANSWIFTCASE_XCODE_PACKAGE_CACHE:-${CASE_ROOT}/.xcode-package-cache/VIPCleanSwiftCase}"
readonly RESULT_BUNDLE_ROOT="${VIPCLEANSWIFTCASE_RESULT_BUNDLE_PATH:-${CASE_ROOT}/.xcode-result-bundles/VIPCleanSwiftCase}"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/verify.sh <static|list|build|test-build|test-unit|test-ui|all>

Levels:
  static     Run static quality gates that do not require simulator execution
  list       Verify Xcode project structure
  build      Build VIPCleanSwiftCase on iPhone 17 Pro (iOS 26.0)
  test-build Build app and tests without launching test execution
  test-unit  Run the unit-test xctestplan only
  test-ui    Run the UI accessibility smoke xctestplan only
  all        Run static, list, build, and unit tests; UI tests remain explicit via test-ui
USAGE
}

run_static() {
  git diff --check
  ./scripts/check_forbidden_patterns.py
  ./scripts/check_secrets.py
  ./scripts/check_large_files.py
  ./scripts/check_localization.py
  ./scripts/check_swiftui_hot_path_patterns.py
}

run_list() {
  xcodebuild \
    -list \
    -project "${PROJECT}" \
    -scheme "${SCHEME}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    -clonedSourcePackagesDirPath "${CLONED_PACKAGES_PATH}"
}

run_build() {
  xcodebuild \
    -project "${PROJECT}" \
    -scheme "${SCHEME}" \
    -configuration Debug \
    -destination "${DESTINATION_IOS_26}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    -clonedSourcePackagesDirPath "${CLONED_PACKAGES_PATH}" \
    CODE_SIGNING_ALLOWED=NO \
    build
}

run_test_build() {
  xcodebuild \
    -project "${PROJECT}" \
    -scheme "${SCHEME}" \
    -testPlan "${UNIT_TEST_PLAN}" \
    -configuration Debug \
    -destination "${DESTINATION_IOS_26}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    -clonedSourcePackagesDirPath "${CLONED_PACKAGES_PATH}" \
    CODE_SIGNING_ALLOWED=NO \
    build-for-testing
}

run_unit_tests() {
  local result_bundle_path="${RESULT_BUNDLE_ROOT}/unit.xcresult"
  rm -rf "${result_bundle_path}"
  mkdir -p "${RESULT_BUNDLE_ROOT}"
  xcodebuild \
    -project "${PROJECT}" \
    -scheme "${SCHEME}" \
    -testPlan "${UNIT_TEST_PLAN}" \
    -configuration Debug \
    -destination "${DESTINATION_IOS_26}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    -clonedSourcePackagesDirPath "${CLONED_PACKAGES_PATH}" \
    -resultBundlePath "${result_bundle_path}" \
    CODE_SIGNING_ALLOWED=NO \
    test
}

run_ui_tests() {
  local result_bundle_path="${RESULT_BUNDLE_ROOT}/ui.xcresult"
  rm -rf "${result_bundle_path}"
  mkdir -p "${RESULT_BUNDLE_ROOT}"
  xcodebuild \
    -project "${PROJECT}" \
    -scheme "${SCHEME}" \
    -testPlan "${UI_TEST_PLAN}" \
    -configuration Debug \
    -destination "${DESTINATION_IOS_26}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    -clonedSourcePackagesDirPath "${CLONED_PACKAGES_PATH}" \
    -resultBundlePath "${result_bundle_path}" \
    CODE_SIGNING_ALLOWED=NO \
    test
}

main() {
  if [[ $# -ne 1 ]]; then
    usage
    exit 1
  fi

  case "$1" in
    static)
      run_static
      ;;
    list)
      run_list
      ;;
    build)
      run_build
      ;;
    test-build)
      run_test_build
      ;;
    test-unit)
      run_unit_tests
      ;;
    test-ui)
      run_ui_tests
      ;;
    all)
      run_static
      run_list
      run_build
      run_unit_tests
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
