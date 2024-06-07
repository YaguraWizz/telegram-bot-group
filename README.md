---

**Инструкции по установке TelegramBot**

**Для Ubuntu:**

1. Откройте терминал.

2. Выполните следующие команды:
   ```
   git clone https://github.com/YaguraWizz/telegram-bot-group.git
   cd telegram-bot-group
   chmod +x init.sh
   sudo ./init.sh
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
   git clone https://github.com/YaguraWizz/telegram-bot-group.git
   cd telegram-bot-group
   .\setup-project.ps1
   ```


Возможные вариант запуска 

sudo ./init.sh start-locale
sudo ./init.sh build
sudo ./init.sh rbuild
sudo ./init.sh create-service
sudo ./init.sh start-service
sudo ./init.sh status-service
sudo ./init.sh stop-service
sudo ./init.sh path
sudo ./init.sh rdev
sudo ./init.sh rcore


chmod +x test_inc.sh