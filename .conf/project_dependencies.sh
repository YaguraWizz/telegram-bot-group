#!/bin/bash
set -e

FILE_NAME="dependencies.txt"
# Определение пути к файлу с зависимостями относительно текущего каталога скрипта
DEPENDENCIES_FILE=$(realpath "../.data/$FILE_NAME")
echo "Полный путь до файла с зависимостями: $DEPENDENCIES_FILE"
log "Полный путь до файла с зависимостями: $DEPENDENCIES_FILE"

# Проверка наличия файла с зависимостями
if [ ! -f "$DEPENDENCIES_FILE" ]; then
    echo "Ошибка: Файл с зависимостями не найден."
    log "Ошибка: Файл с зависимостями не найден."
    exit 1
fi

# Установка зависимостей из файла
while IFS= read -r line || [[ -n "$line" ]]; do
    # Парсинг имени и версии пакета из строки зависимости
    package_name=$(echo "$line" | awk -F' --version ' '{print $1}')
    package_version=$(echo "$line" | awk -F' --version ' '{print $2}')
    echo "Установка зависимости $package_name версии $package_version ..."
    # Проверка наличия зависимости
    if dotnet list package | grep -q "$package_name"; then
        echo "Зависимость $package_name уже установлена."
        log "Зависимость $package_name уже установлена."
    else
        echo "Установка зависимости $package_name версии $package_version ..."
        log "Установка зависимости $package_name версии $package_version ..."
        dotnet add package "$package_name" --version "$package_version" >> "$LOG_FILE"
    fi
done < "$DEPENDENCIES_FILE"

echo "Установка зависимостей завершена."
log "Установка зависимостей завершена."
