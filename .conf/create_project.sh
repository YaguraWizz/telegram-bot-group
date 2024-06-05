#!/bin/bash
set -e

log "Cоздания проекта ..."
# Название проекта
PROJECT_NAME="telegram-bot-project"

# Путь к исходным файлам (изменен на поддиректорию)
SOURCE_PATH="sours"

# Удаление папки проекта, если она уже существует, и создание новой
if [ -d "$PROJECT_NAME" ]; then
    log "Удаление существующего проекта $PROJECT_NAME..."
    rm -rf "$PROJECT_NAME"
fi

# Создание нового проекта
dotnet new console -o "$PROJECT_NAME" >> "$LOG_FILE"
log "Проект $PROJECT_NAME создан."

# Переход в директорию проекта
cd "$PROJECT_NAME"

# Получение полного пути до папки с исходными файлами
FULL_SOURCE_PATH=$(realpath "../$SOURCE_PATH") # изменено относительно текущей директории
log "Полный путь до папки с исходными файлами: $FULL_SOURCE_PATH"
echo "Полный путь до папки с исходными файлами: $FULL_SOURCE_PATH"

# Проверка на существование папки
if [ ! -d "$FULL_SOURCE_PATH" ]; then
    log "Ошибка: Папка с исходными файлами не найдена."
    echo "Ошибка: Папка с исходными файлами не найдена."
    exit 1
fi

# Копирование исходных файлов в каталог проекта
cp -r "$FULL_SOURCE_PATH/." .
log "Исходные файлы скопированы в проект."
