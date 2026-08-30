#!/usr/bin/env bash
set -euo pipefail

readonly PROJECT="MVPPassiveViewCase.xcodeproj"
readonly SCHEME="MVPPassiveViewCase"
readonly UNIT_TEST_PLAN="MVPPassiveViewCase"
readonly UI_TEST_PLAN="MVPPassiveViewCaseUI"
readonly BUILD_DESTINATION="generic/platform=iOS Simulator"
readonly TEST_DESTINATION="${MVP_PASSIVE_VIEW_CASE_TEST_DESTINATION:-platform=iOS Simulator,name=Any iOS Simulator Device}"
readonly CASE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
readonly DERIVED_DATA_PATH="${MVP_PASSIVE_VIEW_CASE_DERIVED_DATA_PATH:-${CASE_ROOT}/.xcode-derived-data/MVPPassiveViewCase}"
readonly CLONED_PACKAGES_PATH="${MVP_PASSIVE_VIEW_CASE_XCODE_PACKAGE_CACHE:-${CASE_ROOT}/.xcode-package-cache/MVPPassiveViewCase}"
readonly RESULT_BUNDLE_ROOT="${MVP_PASSIVE_VIEW_CASE_RESULT_BUNDLE_PATH:-${CASE_ROOT}/.xcode-result-bundles/MVPPassiveViewCase}"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/verify.sh <static|list|build|test-build|test-unit|test-ui|all>

Levels:
  static     Run static quality gates that do not require simulator execution
  list       Verify Xcode project structure
  build      Build MVPPassiveViewCase with a generic iOS Simulator destination
  test-build Run build-for-testing without launching a simulator
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
    -destination "${BUILD_DESTINATION}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    -clonedSourcePackagesDirPath "${CLONED_PACKAGES_PATH}" \
    CODE_SIGNING_ALLOWED=NO \
    build
}

run_test_build() {
  xcodebuild \
    -project "${PROJECT}" \
    -scheme "${SCHEME}" \
    -configuration Debug \
    -destination "${BUILD_DESTINATION}" \
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
    -destination "${TEST_DESTINATION}" \
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
    -destination "${TEST_DESTINATION}" \
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
