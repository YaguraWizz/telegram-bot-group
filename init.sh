#!/bin/bash
set -e



#################################################################
ROOT_PROJECT_NAME="telegram-bot-group"                                              # Название корневого каталога проекта 
PROJECT_NAME="telegram-bot-project"                                                 # Название каталога проекта
SERVICE_NAME="telegram-bot.service"                                                 # Название файла службы
LOG_FILE_NAME="logfile.log"                                                         # Название файла логов 
DEPENDENCIES_FILE_NAME="dependencies.json"                                          # Название файла зависимостей 
#################################################################                                                                     
ROOT_PATH_DIR="$(realpath "$(dirname "$BASH_SOURCE")/")"                            # Путь до корневого каталога проекта 
PROJECT_DIR="$ROOT_PATH_DIR/$PROJECT_NAME"                                          # Путь до каталога проекта 
LOG_PATH_FILE="$ROOT_PATH_DIR/.conf/$LOG_FILE_NAME"                                 # Путь до файла LOG_FILE_NAME
SOURCE_PATH="$ROOT_PATH_DIR/source"                                                 # Путь до каталога с исходными файлами проекта 
DEPENDENCIES_PATH_FILE="$ROOT_PATH_DIR/.conf/$DEPENDENCIES_FILE_NAME"               # Путь до файла DEPENDENCIES_NAME_FILE
SERVICE_PATH_FILE="$ROOT_PATH_DIR/.conf/$SERVICE_NAME"                              # Путь до файла SERVICE_NAME
SYSTEMD_SERVICE_DIR="/etc/systemd/system/$SERVICE_NAME"                             # Путь до ссылки на файл SERVICE_NAME расположенной SERVICE_PATH_FILE
#################################################################






########-----------------ЛОГИРОВАНИЕ---------------------########
#################################################################
# Цвета текста
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

declare -A ERROR_PATH=(
    [ERROR_COUNT]=0
    [DESCRIPTION]="[\n"
    [OUTPUT_SHOW_DEPENDENCIES]="-fc"
)

function log(){
    local msg="$1"            # Message to log
    local out="$2"            # Output type: -f for file, -c for console, -fc for both
    local format_data="$3"    # -d to avoid date, empty otherwise

    # Function to format the message with or without date
    format_msg() {
        local message="$1"
        if [ "$format_data" == "-d" ]; then
            echo -ne "$message"
        else
            echo -ne "$(date '+%Y-%m-%d %H:%M:%S') - $message"
        fi
    }

    # Function to remove color codes
    remove_colors() {
        echo -ne "$1" | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g'
    }

    # Check if the message is empty and log an empty line if true
    if [ -z "$msg" ]; then
        msg=""
    fi

    # Determine the output based on the flags provided
    case "$out" in
        -f)
            format_msg "$(remove_colors "$msg")" >> "$LOG_PATH_FILE"
            echo "" >> "$LOG_PATH_FILE"
            ;;
        -c)
            format_msg "$msg"
            echo ""
            ;;
        -fc)
            format_msg "$(remove_colors "$msg")" >> "$LOG_PATH_FILE"
            echo "" >> "$LOG_PATH_FILE"
            format_msg "$msg"
            echo ""
            ;;
        -fn)
            format_msg "$(remove_colors "$msg")" >> "$LOG_PATH_FILE"
            ;;
        -cn)
            format_msg "$msg"
            ;;
        -fcn)
            format_msg "$(remove_colors "$msg")" >> "$LOG_PATH_FILE"
            format_msg "$msg"
            ;;
        -fce)
            format_msg "$(remove_colors "$msg")" >> "$LOG_PATH_FILE"
            echo "" >> "$LOG_PATH_FILE"
            format_msg "${RED}$(remove_colors "$msg")${NC}"
            echo ""
            ;;
        -ce)
            format_msg "${RED}$(remove_colors "$msg")${NC}"
            echo ""
            ;;
        *)
            return
            ;;
    esac
}
#################################################################
########-----------------ЛОГИРОВАНИЕ---------------------########






########------------------ПРОВЕРКИ-----------------------########
#################################################################
function show_dependencies() {
    if [[ $1 == "-с" ]]; then
        ERROR_PATH["OUTPUT_SHOW_DEPENDENCIES"]="-f"
    else
        ERROR_PATH["OUTPUT_SHOW_DEPENDENCIES"]="-fc"
    fi

    local out=${ERROR_PATH["OUTPUT_SHOW_DEPENDENCIES"]}

    log "${YELLOW}\t\t\t File Names${NC}" $out -d
    validate_and_display "Project Directory Name         = "  "-dn"  "$ROOT_PATH_DIR"            "$PROJECT_NAME"           
    validate_and_display "Root Directory Name            = "  "-dn"  "$ROOT_PATH_DIR"            "$ROOT_PROJECT_NAME"      
    validate_and_display "Service Name                   = "  "-fd"  "$ROOT_PATH_DIR/.conf"      "$SERVICE_NAME"      
    validate_and_display "Log File Name                  = "  "-fd"  "$ROOT_PATH_DIR/.conf/"     "$LOG_FILE_NAME"          
    validate_and_display "Dependencies File Name         = "  "-fd"  "$ROOT_PATH_DIR/.conf"      "$DEPENDENCIES_FILE_NAME" 

    log "${YELLOW}\n\t\t\t Project Path${NC}" $out -d
    validate_and_display "Root Path Directory            = "  "-fds"   "$ROOT_PATH_DIR"                        
    validate_and_display "Project Path Directory         = "  "-fds"   "$PROJECT_DIR"                        
    validate_and_display "Log File Path                  = "  "-fds"   "$LOG_PATH_FILE"                      
    validate_and_display "Source Code Path Directory     = "  "-fds"   "$SOURCE_PATH"                       
    validate_and_display "Dependencies File Path         = "  "-fds"   "$DEPENDENCIES_PATH_FILE"             
    validate_and_display "Service File Path              = "  "-fds"   "$SERVICE_PATH_FILE"                  
    validate_and_display "Systemd Service Path Directory = "  "-fds"   "$(dirname "$SYSTEMD_SERVICE_DIR")"  

    log "" $out -d
    ERROR_PATH["DESCRIPTION"]+="]"

    log "${RED}Total errors: ${ERROR_PATH["ERROR_COUNT"]} ${NC}" $out -d  # Выводим количество ошибок
    log "${RED}Description: ${ERROR_PATH["DESCRIPTION"]} ${NC}" $out -d  # Выводим описание ошибок
}

validate_and_display() {
    local label="$1"
    local mode="$2"
    local path="$3"
    local name="$4"

    # Обрезаем пробелы и равенства из disc
    local pars_label=$(echo "$label" | sed 's/ *= */=/g')

    if [[ "$mode" == "-fd" ]]; then
        # Проверка наличия файла в каталоге (путь + имя файла раздельно)
        if [[ -e "$path/$name" ]]; then
            log "${label}${GREEN}$name${NC}" $out -d
        else
            ((++ERROR_PATH["ERROR_COUNT"]))
            ERROR_PATH["DESCRIPTION"]+="\t$pars_label $name\n"
            log "${label}${RED}$name${NC}" $out -d
        fi
    elif [[ "$mode" == "-fds" ]]; then
        # Проверка наличия файла (путь + имя файла вместе)
        if [[ -e "$path" ]]; then
            log "${label}${GREEN}$path${NC}" $out -d
        else
            ((++ERROR_PATH["ERROR_COUNT"]))
            ERROR_PATH["DESCRIPTION"]+="\t$pars_label $path\n"
            log "${label}${RED}$path${NC}" $out -d
        fi
    elif [[ "$mode" == "-dn" ]]; then
        # Проверка пути до каталога и имени каталога раздельно
        if [[ -d "$path" ]]; then
            log "${label}${GREEN}$name${NC}" $out -d
        else
            ((++ERROR_PATH["ERROR_COUNT"]))
            ERROR_PATH["DESCRIPTION"]+="\t$pars_label $name\n"
            log "${label}${RED}$name${NC}" $out -d
        fi
    fi
}

function check_permission_denied(){
    if [ "$EUID" -ne 0 ]; then
        log "Please run this script with sudo." -c
        exit 1
    else
        # Проверяем существование файла и каталога
        if [ ! -f "$LOG_PATH_FILE" ] || [ ! -d "$(dirname "$LOG_PATH_FILE")" ]; then
            # Создаем каталог, если его нет
            mkdir -p "$(dirname "$LOG_PATH_FILE")"
            # Создаем файл, если его нет
            touch "$LOG_PATH_FILE"
        else
            # Если файл существует, очищаем его содержимое
            echo -n "" > "$LOG_PATH_FILE"
        fi
    fi
}

#################################################################
########------------------ПРОВЕРКИ-----------------------########






########--------------------ПРОЕКТ-----------------------########
#################################################################

# Команды для создания проекта
function create_project(){
    # Удаление папки проекта, если она уже существует, и создание новой
    if [ -d "$PROJECT_DIR" ]; then
        log "Удаление существующего проекта $PROJECT_DIR..."  -fce
        rm -rf "$PROJECT_DIR"
    fi
    log "Создание нового проекта."  -fc
    # Создание нового проекта
    if ! dotnet new console -o "$PROJECT_DIR" >> "$LOG_PATH_FILE"; then
        log "Ошибка создания проекта."  -fce
        exit 1
    fi
    log "Копирование исходных файлов по пути $SOURCE_PATH"  -fc
    if [ ! -d "$SOURCE_PATH" ]; then
        log "Каталог $SOURCE_PATH не существует."  -fce
        exit 1
    fi

    # Копирование файлов в проект
    if ! cp -r "$SOURCE_PATH/." "$PROJECT_DIR"; then
        log "Ошибка копирования исходных файлов в проект." -fce
        exit 1
    fi
    
    log "Исходные файлы скопированы в проект." -fc
    log "Проект создан." -fc
}

# Команды для сборки проекта
function build_project() {
    cd "$PROJECT_DIR"
    log "Сборка проекта $PROJECT_NAME ..." -fc
    if dotnet restore >> "$LOG_PATH_FILE" && dotnet build >> "$LOG_PATH_FILE"; then
        log "Сборка проекта завершена успешно." -fc
    else
        log "Ошибка сборки проекта. Подробности смотрите в файле логов: $LOG_PATH_FILE" -fc
    fi
}

# Команды для пересборки проекта
function rbuild_project() {
    cd "$PROJECT_DIR"
    log "Очистка и сборка проекта $PROJECT_NAME ..." -fc
    if dotnet clean >> "$LOG_PATH_FILE" && dotnet build >> "$LOG_PATH_FILE"; then
        log "Очистка и сборка проекта завершена успешно." -fc
    else
        log "Ошибка очистки и сборки проекта. Подробности смотрите в файле логов: $LOG_PATH_FILE" -fc
    fi
}

function remove_dev_dependencies() {
    log "Удаление dev зависимостей..." -fc
    # Код для удаления dev зависимостей
    # Например, можно использовать команду apt-get remove для удаления пакетов
    while IFS=": " read -r package_name _; do
        sudo apt-get remove --purge -y "$package_name" &>> "$LOG_PATH_FILE"
    done < <(jq -r '.dev | to_entries[] | "\(.key): \(.value)"' "$DEPENDENCIES_PATH_FILE")
}

function remove_core_dependencies() {
    log "Удаление core зависимостей..." -fc
    # Код для удаления core зависимостей
    # Например, можно использовать команду apt-get remove для удаления пакетов
    while IFS= read -r line || [[ -n "$line" ]]; do
        sudo apt-get remove --purge -y "$line" &>> "$LOG_PATH_FILE"
    done < <(jq -r '.core[]' "$DEPENDENCIES_PATH_FILE")
}

# Команды для работы с зависимостями
function reinstall_dev_dependencies() {
    log "Переустановка dev зависимостей..." -fc
    # код для переустановки dev зависимостей
    remove_dev_dependencies
    install_dev_dependencies
}

function reinstall_core_dependencies() {
    log "Переустановка core зависимостей..." -fc
    # код для переустановки core зависимостей
    reinstall_rq
    remove_core_dependencies
    install_core_dependencies
}

# Установить jq
function install_rq() {
    local status
    status=$(command -v jq &> /dev/null)
    log "jq: $(if $status; then echo -e "${GREEN}(установлен)${NC}"; else echo -e "${RED}(не установлен)${NC}"; fi)" -fc
    if ! $status; then
        local rez_inst
        rez_inst=$(sudo apt install -y jq &>> "$LOG_PATH_FILE")
        if $rez_inst; then
            log "начало установки: $rez_inst" -fc
        else
            log "jq: ${RED}(ошибка установки)${NC}" -fce
        fi
    fi
}

function install_dev_dependencies() {
    local current_dir="$(pwd)"
    
    if [ ! -f "$DEPENDENCIES_PATH_FILE" ]; then
        log "Файл $DEPENDENCIES_PATH_FILE не найден." -fce
        return
    fi
    
    sudo apt-get update &>> "$LOG_PATH_FILE" || { log "${RED}Ошибка при обновлении списка пакетов.${NC}" -fce; }
    
    cd "$PROJECT_DIR" || { log "${RED}Ошибка: Невозможно перейти в каталог $PROJECT_DIR${NC}" -fce; return; }

    jq -e '.dev' "$DEPENDENCIES_PATH_FILE" >/dev/null || return

    while IFS=": " read -r package_name package_version; do
        if dotnet list package | grep -q "$package_name"; then
            log "$package_name: ${GREEN}(установлен)${NC}" -fc
        else
            log "$package_name - ${RED}не установлен.${NC} Начало установки: " -fcn
            if ! dotnet add package "$package_name" --version "$package_version" &>> "$LOG_PATH_FILE"; then
                log "" -fc
                log "${RED}Ошибка установки $package_name${NC}" -fce
            fi
            log "${GREEN}установка завершена.${NC}" -fc -d
        fi
    done < <(jq -r '.dev | to_entries[] | "\(.key): \(.value)"' "$DEPENDENCIES_PATH_FILE")

    cd "$current_dir"
}


function install_core_dependencies() {
    install_rq
    if [ ! -f "$DEPENDENCIES_PATH_FILE" ]; then
        log "Файл $DEPENDENCIES_PATH_FILE не найден." -fce
    fi
    
    if sudo apt-get update &>> "$LOG_PATH_FILE"; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            if dpkg -l | grep -q "$line"; then
                log "$line: ${GREEN}(установлен)${NC}" -fc
            else
                log "$line: начало установки: " -fcn
                sudo apt-get install -y "$line" &>> "$LOG_PATH_FILE"
                log "установка завершина" -fc
            fi
        done < <(jq -r '.core[]' "$DEPENDENCIES_PATH_FILE")
    else
        log "Ошибка при обновлении списка пакетов." -fce
    fi
}
#################################################################
########--------------------ПРОЕКТ-----------------------########






########--------------------СЛУЖБА-----------------------########
#################################################################

# Команды для управления службой
function start_service() {
    # Проверяем, запущена ли служба перед её запуском
    log "Проверка статуса службы перед запуском..." -fc
    if service_status; then
        log "Служба уже запущена, нет необходимости запускать." -fce
        return
    fi

    # Перезагружаем systemd
    sudo systemctl daemon-reload >> "$LOG_PATH_FILE" 2>&1
    log "Systemd перезагружен" -fc

    # Запускаем службу
    log "Запуск службы - " -fcn
    if sudo systemctl start $SERVICE_NAME >> "$LOG_PATH_FILE" 2>&1; then
        log "${GREEN}(успешно)${NC}" -fc -d
        return
    else
        log "Ошибка при запуске службы" -fce -d
        return 1
    fi
}

function stop_service() {
    local out=$1
    log "Остановка службы - " "${out}n"

    log "" -f -d

    if sudo systemctl stop $SERVICE_NAME >> "$LOG_PATH_FILE" 2>&1; then
        log "${GREEN}(успешно)${NC}" "$out" -d
        return
    else
        log "Ошибка при остановке службы" "${out}e" -d
        return 1
    fi
}

function service_status() {
    local out=$1
  
    log "Статус службы ${SERVICE_NAME} - " "${out}n" 
    if sudo systemctl is-active $SERVICE_NAME >/dev/null 2>&1; then
        log "${GREEN}активна${NC}" $out -d
        return 0
    else
        log "неактивна" "${out}e" -d
        return 1
    fi
}



function create_service_file() {
    log "Создание файла .service ..." -fc

    stop_service -f

    # Удаляем файл службы, если он уже существует
    if [ -e "$SERVICE_PATH_FILE" ]; then
        log "Удаление существующего файла службы: $SERVICE_PATH_FILE" -fce
        sudo rm "$SERVICE_PATH_FILE"
    fi

    # Записываем конфигурацию службы в файл с пробелами и переходами на новую строку
    echo "
    [Unit]
        Description=Telegram Bot Service
        After=network.target

    [Service]
        User=admin
        WorkingDirectory=$PROJECT_DIR
        ExecStart=/usr/bin/dotnet $PROJECT_DIR/bin/Debug/net8.0/$PROJECT_NAME.dll
        Restart=always
        RestartSec=10
        SyslogIdentifier=telegram-bot

    [Install]
        WantedBy=multi-user.target
    " > "$SERVICE_PATH_FILE"


    log "Файл $SERVICE_NAME создан" -fc

    # Создаем ссылку на службу в каталоге служб
    sudo ln -sf "$SERVICE_PATH_FILE" "$SYSTEMD_SERVICE_DIR"

    log "Ссылка на службу создана" -fc
}
#################################################################
########--------------------СЛУЖБА-----------------------########






#################################################################

# Команды для локального запуска
function start_locale() {
    log "Запуск приложения локально..." -fc
    dotnet run
}

# Функция для выполнения команды
function execute_command() {
    case "$1" in
        "start-locale")
            start_locale
            ;;
        "build")
            build_project
            ;;
        "rbuild")
            rebuild_project
            ;;
        "create-service")
            create_service_file
            ;;
        "start-service")
            start_service -fc
            ;;
        "status-service")
            service_status -fc
            ;;
        "stop-service")
            stop_service -fc
            ;;
        "path")
            show_dependencies 
            ;;
        "rdev")
            reinstall_dev_dependencies
            ;;
        "udev")
            remove_dev_dependencies
            ;;
        "rcore")
            reinstall_core_dependencies
            ;;
        "ucore")
            remove_core_dependencies
            ;;
        "dev")
            install_dev_dependencies
            ;;
        "core")
            install_core_dependencies
            ;;
        "create-project")
            create_project
            ;;
        "start-create-project")
            install_core_dependencies
            create_project
            install_dev_dependencies
            ;;
        *)
            echo "Invalid command: $1"
            ;;
    esac
}

function help(){
    # Вывод справочной информации при отсутствии аргументов
    if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "-help" ] || [ "$1" == "help" ]; then
        log "${RED} Invalid command or combination of commands.                                     "   -c -d   
        log "${RED}              PROJECT COMMAND                                                    "   -c -d
        log "${YELLOW} 1) start-locale - запустить локально                                         "   -c -d
        log "${YELLOW} 2) build - собрать проект                                                    "   -c -d
        log "${YELLOW} 3) rbuild - очистить и собрать проект                                        "   -c -d
        log "${YELLOW} 4) rdev - переустановить dev зависимости                                     "   -c -d
        log "${YELLOW} 5) udev - удались все dev зависимости                                        "   -c -d
        log "${YELLOW} 6) rcore - переустановить core зависимости                                   "   -c -d
        log "${YELLOW} 7) ucore - удались все core зависимости                                      "   -c -d
        log "${YELLOW} 8) dev - проверка наличия dev зависимостей. При отсутствии установить        "   -c -d
        log "${YELLOW} 9) core - проверка наличия core зависимостей. При отсутствии установить      "   -c -d
        log "${YELLOW} 10) create-project - создать/пересоздать проект                              "   -c -d
        log "${RED}              SERVICE COMMAND                                                    "   -c -d
        log "${YELLOW} 11) create-service - создать файл службы                                     "   -c -d
        log "${YELLOW} 12) start-service - запустить службу                                         "   -c -d
        log "${YELLOW} 13) status-service - статус работы службы                                    "   -c -d
        log "${YELLOW} 14) stop-service - остановить работу службы                                  "   -c -d
        log "${RED}              DIAGNOSTICS                                                        "   -c -d
        log "${YELLOW} 15) path - вывод зависимых путей                                             "   -c -d
        log "${RED}              COMBO COMAND                                                       "   -c -d
        log "${YELLOW} 16) start-create-project - создать проект со всем зависимостями              "   -c -d
        exit 
    fi
}

#################################################################


# Главная функция для управления службой
function manage_service() {
    check_permission_denied
    help $1 $2 $3 $4
    if [ -n "$1" ]; then
        execute_command "$1"
    fi
    if [ -n "$2" ]; then
        execute_command "$2"
    fi
    if [ -n "$3" ]; then
        execute_command "$3"
    fi
    if [ -n "$4" ]; then
        execute_command "$4"
    fi
}

manage_service $1 $2 $3 $4