#!/bin/bash
set -uo pipefail

# Константы и переменные
FOLDER_NAME="$HOME/myfolder"

# Проверка существования папки, дла понимания отработал ли script1.sh или нет
echo "Проверяю наличие папки"
if [ ! -d "$FOLDER_NAME" ]; then
    echo "Папка myfolder не найдена"
    exit 0
else
    echo "Папка myfolder найдена"
fi

# Узнаем колличество файлов в папке
COUNT=$(find "$FOLDER_NAME" -maxdepth 1 -type f | wc -l)
echo "Количество файлов в myfolder : $COUNT"

# Меняем права файлу2
if [ -f "$FOLDER_NAME/file2.txt" ]; then
    chmod 664 "$FOLDER_NAME/file2.txt"
    echo "Права файла file2.txt: $(ls -l "$FOLDER_NAME/file2.txt" | awk '{print $1}')"
fi

# Удаляем пустые файлы
echo " Удалены пустые файлы: "
find "$FOLDER_NAME" -maxdepth 1 -type f -empty -print -delete

# Удаляем все строки, кроме первой в файлах
for f in "$FOLDER_NAME"/*; do
    [ -f "$f" ] || continue
    sed -i '1!d' "$f"
done

echo "Готово"
