#!/bin/bash
set -uo pipefail

FOLDER="$HOME/myfolder"
RANDOM_STRING=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
HELLO="Привествую"
DATE="$(date)"


mkdir -p "$FOLDER"

{
    echo "$HELLO"
    echo "$DATE"
} > "$FOLDER/file1.txt"

: > "$FOLDER/file2.txt"
chmod 777 "$FOLDER/file2.txt"


echo "$RANDOM_STRING" > "$FOLDER/file3.txt"

: > "$FOLDER/file4.txt"
: > "$FOLDER/file5.txt"

echo "Готово"
