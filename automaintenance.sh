#!/bin/bash


# Запрос пути к каталогу исходников сервера
read -p "Введите полный путь к каталогу с исходными файлами библиотеки (например, /path/to/openvpn-host): " MAINTENANCE_SCRIPT


# Проверка, существует ли указанные файлы (maintenance.sh и enable-ip-forwarding.sh)
if [ ! -f "$MAINTENANCE_SCRIPT/maintenance.sh" ]; then
    echo "Скрипт обслуживания openvpn не найден по указанному пути: $MAINTENANCE_SCRIPT/maintenance.sh."
    exit 1
fi
if [ ! -f "$MAINTENANCE_SCRIPT/enable-ip-forwarding.sh" ]; then
    echo "Скрипт обслуживания ip-forwarding не найден по указанному пути: $MAINTENANCE_SCRIPT/enable-ip-forwarding.sh."
    exit 1
fi


# Лог-файл для записи результатов работы скрипта обслуживания
LOG_FILE="/var/log/openvpn_maintenance.log"


# Maintenance
# Проверка, добавлено ли уже задание для данного скрипта в cron
if crontab -l 2>/dev/null | grep -Fq "$MAINTENANCE_SCRIPT/maintenance.sh"; then
    echo "Задание для обслуживания уже добавлено в cron."
else
    echo "Добавление задания для обслуживания в cron..."

    # Добавление задания в cron для ежедневного запуска в 3:00
    (crontab -l 2>/dev/null; echo "0 3 * * * $MAINTENANCE_SCRIPT/maintenance.sh > $LOG_FILE 2>&1") | crontab -

    echo "Задание для обслуживания добавлено в cron."
fi


# IP-forwarding
# Проверка, добавлено ли уже задание для данного скрипта в cron
if crontab -l 2>/dev/null | grep -Fq "$MAINTENANCE_SCRIPT/enable-ip-forwarding.sh"; then
    echo "Задание для обслуживания уже добавлено в cron."
else
    echo "Добавление задания для обслуживания в cron..."

    # Добавление задания в cron для ежедневного запуска в 3:00
    (crontab -l 2>/dev/null; echo "0 3 * * * $MAINTENANCE_SCRIPT/enable-ip-forwarding.sh > $LOG_FILE 2>&1") | crontab -

    echo "Задание для обслуживания добавлено в cron."
fi


echo "Проверка завершена."
