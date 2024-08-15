#!/bin/bash

FFMPEG_PATH="ffmpeg"
LOG_FILE="./media_checker.log"

# Detect if the script is running on Windows (Git Bash, Cygwin, etc.)
is_windows() {
    [[ "$(uname -s)" =~ ^MINGW64_NT|^MSYS_NT|^CYGWIN_NT ]]
}

# Convert Unix path to Windows path using cygpath if running on Windows
convert_path() {
    local path="$1"
    if is_windows; then
        cygpath -w "$path"
    else
        printf "%s" "$path"
    fi
}

# Check a single media file for corruption
check_media_file() {
    local file="$1"
    local converted_file; converted_file=$(convert_path "$file")

    if ! "$FFMPEG_PATH" -v error -i "$converted_file" -f null - 2> >(grep -qE 'Invalid data found|Error while decoding'); then
        printf "ERROR: Potential corruption in file: %s\n" "$file" >> "$LOG_FILE"
    fi
}

# Recursively scan directories and store file paths in an array
scan_directory() {
    local dir="$1"
    local -n files_ref="$2"

    while IFS= read -r -d '' file; do
        files_ref+=("$file")
    done < <(find "$dir" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.mp3" -o -iname "*.flac" \) -print0)
}

# Main function
main() {
    > "$LOG_FILE"  # Empty the log file before starting

    if [[ $# -eq 0 ]]; then
        printf "Usage: %s <file_or_directory> [<file_or_directory>...]\n" "$0" >&2
        return 1
    fi

    if is_windows; then
        printf "Running on Windows.\n"
    else
        printf "Running on Linux.\n"
    fi

    declare -a media_files

    for path in "$@"; do
        if [[ -f "$path" ]]; then
            media_files+=("$path")
        elif [[ -d "$path" ]]; then
            scan_directory "$path" media_files
        else
            printf "Skipping invalid path: %s\n" "$path" >&2
        fi
    done

    local total_files=${#media_files[@]}
    for ((i = 0; i < total_files; i++)); do
        printf "Checking (%d/%d): %s\n" $((i + 1)) "$total_files" "${media_files[$i]}"
        check_media_file "${media_files[$i]}"
    done

    printf "Corruption check complete. See %s for details.\n" "$LOG_FILE"
}

# Run the main function with all provided arguments
main "$@"
