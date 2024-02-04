#!/bin/bash

# Source directory (where files are located)
source_dir="Sources"

# Destination directory (where XCTestCase files will be created)
destination_dir="Tests"

# Ensure the destination directory exists, create if not
mkdir -p "$destination_dir"

# Iterate through each file in the source directory
find "$source_dir" -type f -exec sh -c '
    # Get the relative path of the file
    relative_path="${0#'$source_dir/'}"
    
    # Add "Tests" suffix to the file name and directory
    file_name=$(basename -- "$relative_path")
    file_name_no_ext="${file_name%.*}"
    file_name_tests="${file_name_no_ext}Tests"
    
    # Create the corresponding directory in the destination
    destination_path="$2/$(dirname "$relative_path")Tests"
    mkdir -p "$destination_path"
    
    # Create an empty XCTestCase file in the destination directory
    touch "$destination_path/$file_name_tests.swift"
    echo "import XCTest" > "$destination_path/$file_name_tests.swift"
    echo "" >> "$destination_path/$file_name_tests.swift"
    echo "class $file_name_tests: XCTestCase {" >> "$destination_path/$file_name_tests.swift"
    echo "    func testExample() {" >> "$destination_path/$file_name_tests.swift"
    echo "        // Add test logic here." >> "$destination_path/$file_name_tests.swift"
    echo "    }" >> "$destination_path/$file_name_tests.swift"
    echo "}" >> "$destination_path/$file_name_tests.swift"
' {} "$PWD" "$destination_dir" \;

echo "XCTestCase files created in the 'Tests' directory, mirroring the structure from 'Sources'."
