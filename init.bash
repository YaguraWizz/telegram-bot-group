#!/bin/bash

# Проверка наличия .NET SDK 8.0
if dotnet --list-sdks | grep -q "8.0"; then
    echo ".NET SDK 8.0 уже установлен."
else
    echo "Установка .NET SDK 8.0..."
    sudo apt-get update && sudo apt-get install -y dotnet-sdk-8.0
fi

# Проверка наличия ASP.NET Core Runtime 8.0
if dotnet --list-runtimes | grep -q "Microsoft.AspNetCore.App 8.0"; then
    echo "ASP.NET Core Runtime 8.0 уже установлен."
else
    echo "Установка ASP.NET Core Runtime 8.0..."
    sudo apt-get update && sudo apt-get install -y aspnetcore-runtime-8.0
fi

# Создание нового проекта для добавления зависимости
PROJECT_NAME="telegram-bot-project"
if [ ! -d "$PROJECT_NAME" ]; then
    dotnet new console -o $PROJECT_NAME
else
    echo "Проект $PROJECT_NAME уже существует."
fi

# Переход в директорию проекта
cd $PROJECT_NAME

# Проверка наличия библиотеки Telegram.Bot
if dotnet list package | grep -q "Telegram.Bot"; then
    echo "Библиотека Telegram.Bot уже установлена."
else
    echo "Установка библиотеки Telegram.Bot..."
    dotnet add package Telegram.Bot --version 16.0.1
fi

echo "Все зависимости установлены."
