#!/bin/bash

# Check if the script is running with root or sudo privileges
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

frzr-unlock

# Define the path pattern
path_pattern="/usr/share/vim/vim*/defaults.vim"

# Find the matching file paths
file_paths=($path_pattern)

# Check if any matching files are found
if [ ${#file_paths[@]} -eq 0 ]; then
    echo "No matching files found."
    exit 1
fi

# Loop through the matching files and perform the actions
for file_path in "${file_paths[@]}"; do
    # Modify the file using sed
    sed -i 's/set mouse=a/set mouse-=a/g' "$file_path"

    echo "Actions performed on file: $file_path"
done

