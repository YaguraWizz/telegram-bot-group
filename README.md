---

**Инструкции по установке TelegramBot**

**Для Ubuntu:**

1. Откройте терминал.

2. Выполните следующие команды:
   ```
   git clone https://github.com/YaguraWizz/telegramm-bot-group.git
   cd telegramm-bot-group
   chmod +x init.sh
   ./init.sh
   ```

**Для Windows:**

Если у вас возникают проблемы с выполнением скрипта из-за политики выполнения скриптов, выполните следующие действия:

1. Откройте PowerShell от имени администратора.

2. Временно измените политику выполнения с помощью команды:
    ```
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
    ```

3. Выполните следующие команды:
   ```
   git clone https://github.com/YaguraWizz/telegramm-bot-group.git
   cd telegramm-bot-group
   .\setup-project.ps1
   ```
