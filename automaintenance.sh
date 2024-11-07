#!/bin/bash

# Запрос пути к скрипту обслуживания
read -p "Введите полный путь к скрипту обслуживания (например, /path/to/maintenance.sh): " MAINTENANCE_SCRIPT

# Проверка, существует ли указанный файл
if [ ! -f "$MAINTENANCE_SCRIPT" ]; then
    echo "Скрипт обслуживания не найден по указанному пути: $MAINTENANCE_SCRIPT."
    exit 1
fi

# Лог-файл для записи результатов работы скрипта обслуживания
LOG_FILE="/var/log/openvpn_maintenance.log"

# Проверка, добавлено ли уже задание для данного скрипта в cron
if crontab -l 2>/dev/null | grep -Fq "$MAINTENANCE_SCRIPT"; then
    echo "Задание для обслуживания уже добавлено в cron."
else
    echo "Добавление задания для обслуживания в cron..."

    # Добавление задания в cron для ежедневного запуска в 3:00
    (crontab -l 2>/dev/null; echo "0 3 * * * $MAINTENANCE_SCRIPT > $LOG_FILE 2>&1") | crontab -

    echo "Задание для обслуживания добавлено в cron."
fi

echo "Проверка завершена."
