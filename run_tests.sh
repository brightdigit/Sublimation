#!/bin/bash

# Function to run swift test and handle failures
run_test() {
  local dir="$1"
  local basename=`realpath $dir | xargs -I{} basename {}`
  echo "Running tests in $dir"
  (cd "$dir" && swift test) &> "$dir/test_output.log"
  if [ $? -ne 0 ]; then
    echo "Tests failed in $basename. Check $dir/test_output.log for details."
    # Kill all background jobs
    kill $(jobs -p) 2>/dev/null
    exit 1
  fi
  echo "Tests passed in $basename"
}

# Find all directories containing Swift packages in the specified directory (not subdirectories)
package_dirs=(".")
while IFS=  read -r -d $'\0'; do
    package_dirs+=("$REPLY")
done < <(find . -mindepth 1 -maxdepth 2 -type d -exec test -e '{}/Package.swift' \; -print0)

# Run tests in parallel
pids=()
for dir in "${package_dirs[@]}"; do
  run_test "$dir" &
  pids+=($!)
done

# Wait for all tests to complete
for pid in "${pids[@]}"; do
  wait $pid
  if [ $? -ne 0 ]; then
    echo "One of the tests failed. Stopping remaining tests."
    exit 1
  fi
done

echo "All tests passed."