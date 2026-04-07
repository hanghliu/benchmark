#!/bin/bash

# License header checker script
# This script checks if source files have the proper SPDX license header

set -e

LICENSE_PATTERN="SPDX-License-Identifier: MPL-2.0"

echo "Checking SPDX license headers in source files..."

FILES_WITHOUT_LICENSE=""
FILES_CHECKED=0

# Check C++ and CUDA files
for file in $(find . -name "*.cpp" -o -name "*.h" -o -name "*.hpp" -o -name "*.cu" | grep -v "./build" | grep -v "./.git"); do
  if [ -f "$file" ]; then
    FILES_CHECKED=$((FILES_CHECKED + 1))
    if ! head -n 5 "$file" | grep -q "$LICENSE_PATTERN"; then
      FILES_WITHOUT_LICENSE="$FILES_WITHOUT_LICENSE\n  - $file"
    fi
  fi
done

if [ -n "$FILES_WITHOUT_LICENSE" ]; then
  echo "❌ ERROR: Found $FILES_CHECKED files, but the following files are missing the SPDX license header:"
  echo -e "$FILES_WITHOUT_LICENSE"
  echo ""
  echo "Please add the following header to each file:"
  echo "// SPDX-License-Identifier: MPL-2.0"
  exit 1
else
  echo "✅ SUCCESS: All $FILES_CHECKED source files have the proper SPDX license header"
fi