#!/bin/bash

# Lint tooling is pinned in mise.toml. Run `mise install` once so this script
# can find swift-format and periphery locally; CI uses jdx/mise-action.
#
# LINT_MODE:
#   NONE    skip linting entirely
#   INSTALL exit after setup (used by the Xcode aggregate target on install)
#   STRICT  treat swift-format warnings as errors

ERRORS=0

run_command() {
	"$@" || ERRORS=$((ERRORS + 1))
}

if [ "$LINT_MODE" = "INSTALL" ] || [ "$LINT_MODE" = "NONE" ]; then
	exit
fi

echo "LintMode: $LINT_MODE"

if [ -z "$SRCROOT" ]; then
	SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
	PACKAGE_DIR="${SCRIPT_DIR}/.."
else
	PACKAGE_DIR="${SRCROOT}"
fi

# Ensure mise-managed tools are on PATH outside CI (CI uses jdx/mise-action).
if command -v mise >/dev/null 2>&1 && [ -z "$CI" ]; then
	eval "$(mise -C "$PACKAGE_DIR" env -s bash)"
fi

if [ "$LINT_MODE" = "STRICT" ]; then
	SWIFTFORMAT_LINT_OPTIONS="--configuration .swift-format --strict"
else
	SWIFTFORMAT_LINT_OPTIONS="--configuration .swift-format"
fi

pushd "$PACKAGE_DIR" >/dev/null || exit 1

if [ -z "$CI" ]; then
	run_command swift-format format --configuration .swift-format --recursive --parallel --in-place Sources Tests
fi

if [ -z "$FORMAT_ONLY" ]; then
	run_command "$PACKAGE_DIR/Scripts/header.sh" -d "$PACKAGE_DIR/Sources" -c "Leo Dion" -o "BrightDigit" -p "Sublimation"
	run_command swift-format lint --recursive --parallel $SWIFTFORMAT_LINT_OPTIONS Sources
	run_command swift build --build-tests
fi

# Periphery is skipped in CI: it needs an index store from a full build, and
# the build/test jobs already cover compilation.
if [ -z "$FORMAT_ONLY" ] && [ -z "$CI" ]; then
	run_command periphery scan --disable-update-check
else
	echo "Skipping periphery scan."
fi

popd >/dev/null

if [ $ERRORS -gt 0 ]; then
	echo "Linting completed with $ERRORS error(s)"
	exit 1
fi
echo "Linting completed successfully"
