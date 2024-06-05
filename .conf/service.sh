#!/bin/bash
set -e
SCRIPT_DIR="$(dirname "$(dirname "$(readlink -f "$0")")")"
PROJECT_DIR="$SCRIPT_DIR/telegram-bot-project"
SERVICE_DIR="$SCRIPT_DIR/.data"
SERVICE_FILE="$SERVICE_DIR/telegram-bot.service"


# Проверка корректности путей
check_paths() {
    echo "Проверка корректности путей..."

    echo "SCRIPT_DIR: $SCRIPT_DIR"
    echo "PROJECT_DIR: $PROJECT_DIR"
    echo "SERVICE_FILE: $SERVICE_FILE"

    if [ ! -d "$SCRIPT_DIR" ]; then
        echo "Ошибка: Каталог скрипта не существует: $SCRIPT_DIR"
        exit 1
    fi

    if [ ! -d "$PROJECT_DIR" ]; then
        echo "Ошибка: Каталог проекта не существует: $PROJECT_DIR"
        exit 1
    fi

    if [ ! -d "$SERVICE_DIR" ]; then
        echo "Каталог для службы не существует: $SERVICE_DIR. Создаю..."
        mkdir -p "$SERVICE_DIR"
        echo "Каталог создан: $SERVICE_DIR"
    fi

    echo "Пути корректны."
}

# Функция для создания службы
create_service() {
    echo "Создание файла .service ..."
    log "Создание файла .service ..."

    # Удаляем файл службы, если он уже существует
    if [ -e "$SERVICE_FILE" ]; then
        echo "Удаление существующего файла службы: $SERVICE_FILE"
        log "Удаление существующего файла службы: $SERVICE_FILE"
        sudo rm "$SERVICE_FILE"
    fi

    cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Telegram Bot Service
After=network.target

[Service]
User=admin
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/bin/dotnet $PROJECT_DIR/bin/Debug/net8.0/telegram-bot-project.dll
Restart=always
RestartSec=10
SyslogIdentifier=telegram-bot

[Install]
WantedBy=multi-user.target
EOF

    echo "Файл .service создан"
    log "Файл .service создан"

    # Создаем ссылку на службу в каталоге служб
    sudo ln -sf "$SERVICE_FILE" /etc/systemd/system/telegram-bot.service

    echo "Ссылка на службу создана"
    log "Ссылка на службу создана"
}

# Функция для запуска службы
run_service() {
    # Перезагружаем systemd
    sudo systemctl daemon-reload

    echo "Systemd перезагружен"
    log "Systemd перезагружен"

    # Запускаем службу
    sudo systemctl start telegram-bot.service

    echo "Служба запущена"
    log "Служба запущена"

    # Включаем службу для автоматического старта при загрузке системы
    sudo systemctl enable telegram-bot.service

    echo "Служба включена для автоматического старта"
    log "Служба включена для автоматического старта"
}

# Функция для остановки службы
stop_service() {
    echo "Остановка службы..."
    log "Остановка службы..."
    sudo systemctl stop telegram-bot.service
    echo "Служба остановлена"
    log "Служба остановлена"
}

# Функция для проверки статуса службы
check_service_status() {
    echo "Проверка статуса службы..."
    if systemctl is-active --quiet telegram-bot.service; then
        echo "Служба работает."
        log "Служба работает."
    else
        echo "Служба не работает."
        log "Служба не работает."
    fi
}

# Метод инициализации службы
init_service() {
    check_paths
    create_service
    run_service
}


