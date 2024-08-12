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

for i in "${!directories[@]}"; do
    dir="${directories[$i]}"
    if [ -f "$dir/Scripts/lint.sh" ]; then
        echo "Running lint.sh in $dir"
        (cd "$dir" && LINT_MODE="$LINT_MODE" ./Scripts/lint.sh)
        
        # Check if the script failed
        if [ $? -ne 0 ]; then
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
        echo "lint.sh not found in $dir"
    fi
done

echo "All lint processes completed successfully."
