#!/bin/bash
set -uo pipefail

# Константы и переменные
FOLDER_NAME="$HOME/myfolder"
RANDOM_STRING=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
HELLO="Приветствую"
DATE="$(date)"

# Создание папки
mkdir -p "$FOLDER_NAME"

# Создание файла1 и добавление в него строк приветствия, времени и даты
{
    echo "$HELLO"
    echo "$DATE"
} > "$FOLDER_NAME/file1.txt"
echo "содержимое file1: $(cat $FOLDER_NAME/file1.txt)"


# Создание файла2 и назначение прав
: > "$FOLDER_NAME/file2.txt"
chmod 777 "$FOLDER_NAME/file2.txt"
echo "Права файла file2.txt: $(ls -l "$FOLDER_NAME/file2.txt" | awk '{print $1}')"

# Создание файла3 и добавление в него сгенерированных случайных символов
echo "$RANDOM_STRING" > "$FOLDER_NAME/file3.txt"
echo "содержимое file3: $(cat $FOLDER_NAME/file3.txt)"


# Создание пустых файлов 4 и 5
: > "$FOLDER_NAME/file4.txt"
: > "$FOLDER_NAME/file5.txt"

echo "Готово"
