#!/bin/bash
set -uo pipefail

FOLDER="$HOME/myfolder"

echo "Проверяю наличие папки"
if [ ! -d "$FOLDER" ]; then
    echo "Папка myfolder не найдена"
    exit 0
else
    echo "Папка myfolder найдена"
fi

COUNT=$(find "$FOLDER" -maxdepth 1 -type f | wc -l)
echo "Количество файлов в myfolder : $COUNT"

if [ -f "$FOLDER/file2.txt" ]; then
    chmod 664 "$FOLDER/file2.txt"
fi

find "$FOLDER" -maxdepth 1 -type f -empty -delete

for f in "$FOLDER"/*; do
    [ -f "$f" ] || continue
    sed -i '1!d' "$f"
done

echo "Готово"
