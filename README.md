# Media-Checker

This script checks media files for potential corruption using `ffmpeg`. It can handle both individual files and directories. The results of the checks are logged in a file called `media_checker.log`.

## Overview

The script:
- Detects if it is running on Windows (via Git Bash, Cygwin, etc.) or Linux.
- Converts Unix paths to Windows paths when running on Windows.
- Checks media files for corruption using `ffmpeg`.
- Logs any potential corruption issues to `media_checker.log`.
- Handles `.mp4`, `.mkv`, `.mp3`, and `.flac` file formats.

## Requirements

- `ffmpeg` should be installed or available in your PATH.

## Usage

To use the script, run it from the command line with one or more file or directory paths as arguments.

```bash
./media_checker.sh <file_or_directory> [<file_or_directory>...]
