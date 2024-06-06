#!/bin/bash
set -e

# Цвета текста
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Проверка на запуск скрипта с правами sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo."
    exit
fi

ROOT_DIR_NAME="telegram-bot-group"
ROOT_PATH_DIR="$(realpath "$(dirname "$BASH_SOURCE")/")"

PROJECT_NAME="telegram-bot-project"
PROJECT_DIR="$ROOT_PATH_DIR/$PROJECT_NAME"

LOG_PATH_FILE="$ROOT_PATH_DIR/log/logfile.log"
CORRECTNESS_PROJECT_DIRECTOR=false

# Путь к исходным файлам (изменен на поддиректорию)
SOURCE_PATH="$ROOT_PATH_DIR/source"

DEPENDENCIES_PATH_FILE="$ROOT_PATH_DIR/.conf/dependencies.json"

SERVICE_NAME_FILE="telegram-bot.service"
SERVICE_PATH_FILE="$ROOT_DIR_NAME/.conf/$SERVICE_NAME_FILE"


function print_path() {
    echo ""
    echo -e "${YELLOW}\t\t\t File Names${NC}"
    echo -e "${GREEN}Project Name                   = ${NC}${YELLOW}$PROJECT_NAME${NC}"
    echo -e "${GREEN}Root Directory Name            = ${NC}${YELLOW}$ROOT_DIR_NAME${NC}"
    echo -e "${YELLOW}\n\t\t\t Project Path${NC}"
    echo -e "${GREEN}Root Path Directory            = ${NC}${YELLOW}$ROOT_PATH_DIR${NC}"
    echo -e "${GREEN}Project Directory              = ${NC}${YELLOW}$PROJECT_DIR${NC}"
    echo -e "${GREEN}Log File                       = ${NC}${YELLOW}$LOG_PATH_FILE${NC}"
    echo -e "${GREEN}Source Code                    = ${NC}${YELLOW}$SOURCE_PATH${NC}"
    echo -e "${GREEN}Dependencies File              = ${NC}${YELLOW}$DEPENDENCIES_PATH_FILE${NC}"
    echo ""
}






function log() {
    local msg="$1"
    local console="$2"
    local new_line=true
    local no_date=false

    if [ -z "$msg" ]; then
        echo
        return
    fi

    if [ "$3" = "noNewLine" ]; then
        new_line=false
    fi

    if [ "$4" = "noDate" ]; then
        no_date=true
    fi

    if [ "$console" = true ]; then
        if [ "$new_line" = true ]; then
            if [ "$no_date" = true ]; then
                echo -e "${GREEN}$msg${NC}"
            else
                echo -e "$(date +'%Y-%m-%d %H:%M:%S') ${GREEN}$msg${NC}"
            fi
        else
            if [ "$no_date" = true ]; then
                echo -ne "${GREEN}$msg${NC}"
            else
                echo -ne "$(date +'%Y-%m-%d %H:%M:%S') ${GREEN}$msg${NC}"
            fi
        fi
    else
        if [ "$new_line" = true ]; then
            if [ "$no_date" = true ]; then
                echo -e "${GREEN}$msg${NC}" >> "$LOG_PATH_FILE"
            else
                echo -e "$(date +'%Y-%m-%d %H:%M:%S') ${GREEN}$msg${NC}" >> "$LOG_PATH_FILE"
            fi
        else
            if [ "$no_date" = true ]; then
                echo -ne "${GREEN}$msg${NC}" >> "$LOG_PATH_FILE"
            else
                echo -ne "$(date +'%Y-%m-%d %H:%M:%S') ${GREEN}$msg${NC}" >> "$LOG_PATH_FILE"
            fi
        fi
    fi
}


declare -A ERRORS=(
    [BAT_PATH_DIR]=1
    [BAT_NAME_FILE]=2
    [BAT_NOT_FOUND_DIR]=3
    [BAT_NOT_FOUND_FILE]=4
    [BAT_BUILD]=5
    [BAT_INSTALL_CORE]=6
    [BAT_INSTALL_DEV]=7
    [BAT_MOVE_DIR]=8
)

function Error() {
    local msg="$1"
    local type="$2"
    local new_msg="${ERRORS[$type]}: $msg"
    if [ "$CORRECTNESS_PROJECT_DIRECTOR" = false ]; then
        log "${RED}$new_msg${NC}" true
    else
        echo -e "${RED}$new_msg${NC}" >&2
    fi
    exit "$type"
}


function check_path_root_dir(){
    if [ "$(basename "$ROOT_PATH_DIR")" != $ROOT_DIR_NAME ]; then
        Error "определенный путь не соответствует истине.
        Определено: $(basename "$ROOT_PATH_DIR")
        Ожидается: $ROOT_DIR_NAME" BAT_PATH_DIR
    else
        CORRECTNESS_PROJECT_DIRECTOR=true

        # ЛОГИРОВАНИЕ
        # Проверяем и создаем каталог, если он не существует
        if [ ! -d "$(dirname "$LOG_PATH_FILE")" ]; then
            mkdir -p "$(dirname "$LOG_PATH_FILE")"
        fi
        # Проверяем и создаем файл, если он не существует
        if [ ! -f "$LOG_PATH_FILE" ];then
            touch "$LOG_PATH_FILE"
        else
            # Если файл существует, очистить его и записать сообщение
            echo "Файл журнала логов был очищен $(date +'%Y-%m-%d %H:%M:%S')" > "$LOG_PATH_FILE"
        fi
    fi
}

function install_rq(){  
    local status
    status=$(command -v jq &> /dev/null)
    log "jq: $(if $status; then echo -e "${GREEN}(установлен)${NC}"; else echo -e "${RED}(не установлен)${NC}"; fi)" true "noNewLine"
    if ! $status; then
        local rez_inst
        rez_inst=$(sudo apt install -y jq &>> "$LOG_PATH_FILE")
        if $rez_inst; then
            log "начало установки: $rez_inst" true "noNewLine" "noDate"
        else
            log "jq: ${RED}(ошибка установки)${NC}" 
        fi
    fi
    log "" true "NewLine"
}

function check_install_core_dependencies(){
    install_rq
    if [ ! -f "$DEPENDENCIES_PATH_FILE" ]; then
        Error "Файл $DEPENDENCIES_PATH_FILE не найден." BAT_NOT_FOUND_FILE
    fi
    
    if sudo apt-get update &>> "$LOG_PATH_FILE"; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            if dpkg -l | grep -q "$line"; then
                log "$line: (установлен)" true
            else
                log "$line: начало установки: " true "noNewLine" 
                sudo apt-get install -y "$line" &>> "$LOG_PATH_FILE"
                log "установка завершина" true "NewLine" "noDate"
            fi
        done < <(jq -r '.core[]' "$DEPENDENCIES_PATH_FILE")
    else
        log "Ошибка при обновлении списка пакетов." true
    fi
}

function check_install_dev_dependencies(){
    local current_dir="$(pwd)"
    
    if [ ! -f "$DEPENDENCIES_PATH_FILE" ]; then
        Error "Файл $DEPENDENCIES_PATH_FILE не найден." BAT_NOT_FOUND_FILE
        return
    fi
    
    sudo apt-get update &>> "$LOG_PATH_FILE" || { Error "${RED}Ошибка при обновлении списка пакетов.${NC}" "BAT_INSTALL_DEV"; }
    
    cd "$PROJECT_DIR" || { Error "${RED}Ошибка: Невозможно перейти в каталог $PROJECT_DIR${NC}" "BAT_MOVE_DIR"; return; }

    jq -e '.dev' "$DEPENDENCIES_PATH_FILE" >/dev/null || return

    while IFS=": " read -r package_name package_version; do
        if dotnet list package | grep -q "$package_name"; then
            log "$package_name: ${GREEN}(установлен)${NC}" true
        else
            log "$package_name - ${RED}не установлен.${NC} Начало установки: " true "noNewLine" 
            if ! dotnet add package "$package_name" --version "$package_version" &>> "$LOG_PATH_FILE"; then
                log "" true "NewLine" "noDate"
                Error "${RED}Ошибка установки $package_name${NC}" "BAT_INSTALL_DEV"
            fi
            log "установка завершена" true "NewLine" "noDate"
        fi
    done < <(jq -r '.dev | to_entries[] | "\(.key): \(.value)"' "$DEPENDENCIES_PATH_FILE")

    cd "$current_dir"
}

function create_project(){
    # Удаление папки проекта, если она уже существует, и создание новой
    if [ -d "$PROJECT_DIR" ]; then
        log "Удаление существующего проекта $PROJECT_DIR..." false
        rm -rf "$PROJECT_DIR"
    fi

    # Создание нового проекта
    dotnet new console -o "$PROJECT_DIR" >> "$LOG_PATH_FILE"

    if [ ! -e "$SOURCE_PATH" ]; then
        Error "Каталог $SOURCE_PATH не существует." "BAT_NOT_FOUND_DIR"
    fi

    cp -r "$SOURCE_PATH/." "$PROJECT_DIR"
    
    log "Исходные файлы скопированы в проект." true
}

function compile_project(){
    cd "$PROJECT_DIR"
    log "Сборка проекта $PROJECT_NAME ..." true
    if dotnet restore >> "$LOG_PATH_FILE" && dotnet build >> "$LOG_PATH_FILE"; then
        log "Сборка проекта завершена успешно." true
    else
        Error "Ошибка сборки проекта. Подробности смотрите в файле логов: $LOG_PATH_FILE" BAT_BUILD
    fi
}

function run_locally(){
    log "Запуск приложения локально..." true
    dotnet run
}

function build_project_pipeline(){
    check_path_root_dir
    check_install_core_dependencies
    create_project
    check_install_dev_dependencies
    compile_project
}

function init_service(){
    log "Создание файла .service ..." true

    # Удаляем файл службы, если он уже существует
    if [ -e "$SERVICE_PATH_FILE" ]; then
        log "Удаление существующего файла службы: $SERVICE_PATH_FILE" true
        sudo rm "$SERVICE_PATH_FILE"
    fi

    # Записываем конфигурацию службы в файл с пробелами и переходами на новую строку
    echo '
    [Unit]
        Description=Telegram Bot Service
        After=network.target

    [Service]
        User=admin
        WorkingDirectory='"$PROJECT_DIR"'
        ExecStart=/usr/bin/dotnet '"$PROJECT_DIR"'/bin/Debug/net8.0/telegram-bot-project.dll
        Restart=always
        RestartSec=10
        SyslogIdentifier=telegram-bot

    [Install]
        WantedBy=multi-user.target
    ' > "$SERVICE_PATH_FILE"

    log "Файл .service создан" true

    # Создаем ссылку на службу в каталоге служб
    sudo ln -sf "$SERVICE_PATH_FILE" "/etc/systemd/system/$SERVICE_NAME.service"

    log "Ссылка на службу создана" true
}

function stop_service(){
    log "Остановка службы..." true
    sudo systemctl stop telegram-bot.service >> "$LOG_PATH_FILE";
    log "Остановка службы..." true
}

function run_service(){
    # Проверяем, запущена ли служба перед её запуском
    log "Проверка статуса службы перед запуском..." true
    if check_service_status; then
        log "Служба уже запущена, нет необходимости запускать." true
        return
    fi

    # Перезагружаем systemd
    sudo systemctl daemon-reload
    log "Systemd перезагружен" true

    # Запускаем службу
    log "Запуск службы..." true
    sudo systemctl start telegram-bot.service >> "$LOG_PATH_FILE"
    log "Служба успешно запущена." true

    # Включаем службу для автоматического старта при загрузке системы
    sudo systemctl enable telegram-bot.service
    log "Служба включена для автоматического старта." true
}


# Главная функция для управления службой
function manage_service() {
    case "$1" in
        start)
            build_project_pipeline
            init_service
            ;;
        stop)
            stop_service
            ;;
        status)
            check_service_status
            ;;
        locale)
            build_project_pipeline
            run_locally
            ;;
        build)
            compile_project
            ;;
        path)
            print_path
            ;;
        *)
            echo "Использование: $0 {start|stop|status|locale|build|path}"
            exit 1
            ;;
    esac
}

manage_service $1



