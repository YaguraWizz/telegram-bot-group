#!/bin/bash
set -e

LOG_DIR="$(pwd)/.log"
LOG_FILE="$LOG_DIR/logfile.txt"

# Создание директории для лог-файлов, если она не существует
mkdir -p "$LOG_DIR"

function log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
}
