# Определить корневой путь скрипта
$ROOT_DIR_PATH = $PSScriptRoot

# Параметры проекта
$PROJECT_NAME = "telegram-bot-project"
$SOURCE_PATH = "$ROOT_DIR_PATH\source"
$DEPENDENCIES_PATH_FILE = "$ROOT_DIR_PATH\.conf\dependencies.json"

$PROJECT_DIR = "$ROOT_DIR_PATH\$PROJECT_NAME"


# Метод для проверки пути с описанием
function Check-Path {
    param (
        [string]$Path,
        [string]$Description
    )

    if (-Not (Test-Path -Path $Path)) {
        Write-Output "Error: $Description does not exist: $Path"
        exit 1
    } else {
        Write-Output "$Description exists: $Path"
    }
}

# Метод для проверки всех путей
function Check-Paths {
    Check-Path -Path $ROOT_DIR_PATH -Description "Root Directory Path"
    Check-Path -Path $SOURCE_PATH -Description "Source Path"
    Check-Path -Path $DEPENDENCIES_PATH_FILE -Description "Dependencies Path File"
    Check-Path -Path $PROJECT_DIR -Description "Project Directory"
}


function Create-Project{
    param (
       [string]$project_name
    )
    # Создать новый консольный проект
    dotnet new console -o $project_name --force
}


function Copy-To-File-Or-Dir{
    param (
        [string]$from,
        [string]$where
    )

    # Скопировать исходные файлы
    Copy-Item -Path "$from\*" -Destination $where -Recurse -Force
}

function Init-Dev-Dependencies{
    param (
        [string]$dependencies_path_file,
        [string]$project_dir
    )

    # Прочитать JSON файл с зависимостями
    $jsonData = Get-Content -Path $dependencies_path_file | ConvertFrom-Json

    # Получить объект dev
    $devDependencies = $jsonData.dev

    # Выполнить команду dotnet add package для каждого пакета в объекте dev
    foreach ($package in $devDependencies.PSObject.Properties) {
        $packageName = $package.Name
        $packageVersion = $package.Value
        Write-Output "Performance: dotnet add package $packageName --version $packageVersion $project_dir"
        dotnet add $project_dir package $packageName --version $packageVersion
    }
}

function build{
    param (
        [string]$project_dir
    )
    # Сборка проекта
    dotnet build $project_dir
}



function main{
    # Вызов метода для вывода всех путей в консоль
    Check-Paths

    # Создание проекта
    Create-Project -project_name $PROJECT_NAME

    # Копирование исходных файлов
    Copy-To-File-Or-Dir -from $SOURCE_PATH -where $PROJECT_DIR

    # Инициализация зависимостей
    Init-Dev-Dependencies -dependencies_path_file $DEPENDENCIES_PATH_FILE -project_dir $PROJECT_DIR

    # Сборка проекта
    build -project_dir $PROJECT_DIR
}

# Вызов основной функции
main
