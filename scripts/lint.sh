#!/bin/sh

if [ "$ACTION" == "install" ]; then 
	if [ -n "$SRCROOT" ]; then
		exit
	fi
fi

export MINT_PATH="$PWD/.mint"
MINT_ARGS="-n -m Mintfile --silent"
MINT_RUN="/opt/homebrew/bin/mint run $MINT_ARGS"

if [ -z "$SRCROOT" ]; then
	SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
	PACKAGE_DIR="${SCRIPT_DIR}/.."
else
	PACKAGE_DIR="${SRCROOT}" 	
fi


if [ "$LINT_MODE" == "NONE" ]; then
	exit
elif [ "$LINT_MODE" == "STRICT" ]; then
	SWIFTFORMAT_OPTIONS="--strict"
else 
	SWIFTFORMAT_OPTIONS=""
fi

/opt/homebrew/bin/mint bootstrap

#pushd $PACKAGE_DIR

echo "LINT Mode is $LINT_MODE"

if [ -z "$CI" ]; then
	$MINT_RUN swift-format format --recursive --parallel --in-place $PACKAGE_DIR/Sources
else 
	set -e
fi
$MINT_RUN swift-format lint --recursive --parallel $SWIFTFORMAT_OPTIONS $PACKAGE_DIR/Sources

#popd
