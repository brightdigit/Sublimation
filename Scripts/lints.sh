#!/bin/bash

if [ -z "$SRCROOT" ]; then
   script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
   script_dir="${SRCROOT}/Scripts" 
fi

directories=(
    "Packages/Ngrokit"
    "Packages/SublimationBonjour"
    "Packages/SublimationNgrok"
    "Packages/SublimationService"
    "Packages/SublimationVapor"
    "."
)

cd "$script_dir/.." || exit 1

filter_output() {
    local dir="$1"
    while IFS= read -r line; do
        if [[ $line == Sources* ]]; then
            echo "$dir/$line"
        else
            echo "$line"
        fi
    done
}

for i in "${!directories[@]}"; do
    dir="${directories[$i]}"
    if [ -f "$dir/Scripts/lint.sh" ]; then
        echo "Running lint.sh in $dir"
        (
            cd "$dir" && \
            LINT_MODE="$LINT_MODE" CHILD_PACKAGE=1 ./Scripts/lint.sh 2>&1 1>/dev/null | filter_output "$dir" 1>&2
        )
        
        # Check if the script failed
        if [ ${PIPESTATUS[0]} -ne 0 ]; then
            echo "Lint script failed in $dir"
            exit 1
        fi
        
        # Copy .mint folder to the next directory if it's not the last one
        if [ $i -lt $((${#directories[@]} - 1)) ]; then
            next_dir="${directories[$i+1]}"
            if [ -d "$dir/.mint" ]; then
                echo "Copying .mint folder from $dir to $next_dir"
                cp -R "$dir/.mint" "$next_dir/"
            else
                echo "No .mint folder found in $dir"
            fi
        fi
    else
        echo "$dir/Scripts/lint.sh not found."
    fi
done

echo "All lint processes completed successfully."