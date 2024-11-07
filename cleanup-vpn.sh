#!/bin/bash

# Каталог с сертификатами и ключами
CERT_DIR="/etc/openvpn/easy-rsa/pki"
ISSUED_DIR="$CERT_DIR/issued"
PRIVATE_DIR="$CERT_DIR/private"

# Основные файлы, которые нельзя удалять
PROTECTED_FILES=("server.crt" "server.key" "ca.crt" "ca.key" "dh.pem")

# Список доступных конфигураций
echo "Список всех доступных клиентских конфигураций:"
client_configs=()
for client_cert in "$ISSUED_DIR"/*.crt; do
    client_name=$(basename "$client_cert" .crt)
    
    # Пропуск защищенных файлов
    if [[ " ${PROTECTED_FILES[@]} " =~ " $client_name.crt " ]]; then
        continue
    fi

    client_configs+=("$client_name")
    echo "- $client_name"
done

# Запрос у пользователя, какие конфигурации оставить
echo ""
echo "Введите имена конфигураций, которые нужно сохранить, разделенные пробелом:"
read -p "> " -a keep_configs

# Удаление неиспользуемых конфигураций
for client_name in "${client_configs[@]}"; do
    # Проверка, указан ли клиент в списке для сохранения
    if [[ ! " ${keep_configs[@]} " =~ " $client_name " ]]; then
        # Удаление сертификатов и ключей для неиспользуемых конфигураций
        rm -f "$ISSUED_DIR/$client_name.crt" "$PRIVATE_DIR/$client_name.key"
        echo "Конфигурация $client_name удалена."
    else
        echo "Конфигурация $client_name сохранена."
    fi
done

echo "Очистка завершена."
