#!/bin/bash
set -e

# Проверка наличия .NET SDK 8.0
if dotnet --list-sdks | grep -q "8.0"; then
    log ".NET SDK 8.0 уже установлен."
    echo ".NET SDK 8.0 уже установлен."
else
    log "Установка .NET SDK 8.0..."
    echo "Установка .NET SDK 8.0..."
    sudo apt-get update >> "$LOG_FILE" && sudo apt-get install -y dotnet-sdk-8.0 >> "$LOG_FILE"
fi

# Проверка наличия ASP.NET Core Runtime 8.0
if dotnet --list-runtimes | grep -q "Microsoft.AspNetCore.App 8.0"; then
    log "ASP.NET Core Runtime 8.0 уже установлен."
    echo "ASP.NET Core Runtime 8.0 уже установлен."
else
    log "Установка ASP.NET Core Runtime 8.0..."
    echo "Установка ASP.NET Core Runtime 8.0..."
    sudo apt-get update >> "$LOG_FILE" && sudo apt-get install -y aspnetcore-runtime-8.0 >> "$LOG_FILE"
fi

log "Все глобальные зависимости установлены."
echo "Все глобальные зависимости установлены."
