#!/bin/bash
set -e

source .conf/logger.sh  # Исправлено на logger

build_project(){
    # Запуск скрипта для установки глобальных зависимостей
    source .conf/global_dependencies.sh

    # Запуск скрипта для создания проекта
    source .conf/create_project.sh

    # Запуск скрипта для установки зависимостей проекта
    source ../.conf/project_dependencies.sh  # Исправлено путь

    # Запуск скрипта для установки службы
    source ../.conf/service.sh  # Исправлено путь

    # Обновление файла проекта для включения всех файлов
    dotnet restore >> "$LOG_FILE"

    echo "Сборка проекта ..."
    log "Сборка проекта ..."
    dotnet build >> "$LOG_FILE"
}

# Запуск приложения локально
run_locally() {
    echo "Запуск приложения локально ..."
    log "Запуск приложения локально ..."
    
    # Здесь вставьте код для запуска приложения локально
    # Пример:
    dotnet run
}

# Главная функция для управления службой
manage_service() {
    case "$1" in
        start)
            build_project
            init_service
            ;;
        stop)
            stop_service
            ;;
        status)
            check_service_status
            ;;
        locale)
            build_project
            run_locally
            ;;
        build)
            build_project
            ;;
        *)
            echo "Использование: $0 {start|stop|status|locale|build}"
            exit 1
            ;;
    esac
}

# Вызов функции управления службой с переданным аргументом
manage_service "$1"
