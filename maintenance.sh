#!/bin/bash

# Локация логов OpenVPN
LOG_DIR="/var/log"
OPENVPN_LOG="$LOG_DIR/openvpn.log"
OPENVPN_STATUS_LOG="$LOG_DIR/openvpn-status.log"

# Функция для проверки статуса и перезапуска OpenVPN
check_and_restart_openvpn() {
    if ! systemctl is-active --quiet openvpn@server; then
        echo "OpenVPN не работает. Перезапуск..."
        systemctl restart openvpn@server
        if systemctl is-active --quiet openvpn@server; then
            echo "OpenVPN успешно перезапущен."
        else
            echo "Ошибка при перезапуске OpenVPN."
        fi
    else
        echo "OpenVPN работает нормально."
    fi
}

# Функция для обновления OpenVPN и системы
update_system_and_openvpn() {
    echo "Обновление системы и OpenVPN..."
    apt-get update -y
    apt-get upgrade -y              # Обновление всех пакетов
    apt-get install --only-upgrade -y openvpn  # Обновление только OpenVPN, если доступно
    apt-get dist-upgrade -y         # Дополнительные обновления для дистрибутива
    echo "Система и OpenVPN обновлены до последних версий."
}

# Функция для очистки логов OpenVPN
clear_openvpn_logs() {
    echo "Очистка логов OpenVPN..."
    : > "$OPENVPN_LOG"
    : > "$OPENVPN_STATUS_LOG"
    echo "Логи OpenVPN очищены."
}

# Функция для очистки кэшей и временных файлов
clear_cache_and_temp() {
    echo "Очистка кэшей и временных файлов..."
    apt-get clean
    rm -rf /tmp/*
    echo "Кэши и временные файлы очищены."
}

# Функция для очистки системного мусора
clear_system_junk() {
    echo "Очистка системного мусора..."
    
    # Очистка устаревших пакетов и зависимостей
    apt-get autoremove -y
    apt-get autoclean -y

    # Очистка старых архивов логов
    find /var/log -type f -name "*.gz" -exec rm -f {} \;
    find /var/log -type f -name "*.1" -exec rm -f {} \;

    # Очистка кэша журналов systemd
    journalctl --vacuum-time=7d

    echo "Системный мусор очищен."
}

# Основная логика скрипта
echo "Запуск скрипта обслуживания OpenVPN..."

check_and_restart_openvpn
update_system_and_openvpn
clear_openvpn_logs
clear_cache_and_temp
clear_system_junk

echo "Скрипт обслуживания завершен."
