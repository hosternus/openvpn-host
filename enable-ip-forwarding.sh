#!/bin/bash


# Включаем IP-forwarding
echo "Включаем IP-forwarding..."
if (grep -q net.ipv4.ip_forward=1 /etc/sysctl.conf); then
    echo "Редактируем sysctl.conf..."
    echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
else
    echo "Конфигурация sysctl.conf уже настроена"
fi
sysctl -p
echo "IP-forwarding включен"


# Установка пакета iptables-persistent для сохранения правил
echo "Устанавливаем iptables и iptables-persistent для сохранения правил NAT..."
apt-get update -y
apt-get install -y iptables-persistent iptables

# Сброс прошлой конфигурации iptables
rm -rf /etc/iptables/rules.v4
iptables -F

# Определение сетевого интерфейса, через который сервер подключен к Интернету
INTERFACE=$(ip route | grep default | awk '{print $5}')
echo "Используем интерфейс: $INTERFACE"

# Настройка NAT для выхода трафика в Интернет
echo "Настраиваем NAT с использованием iptables..."
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o "$INTERFACE" -j MASQUERADE

# Сохранение правил iptables для загрузки при старте системы
echo "Сохраняем правила iptables..."
iptables-save > /etc/iptables/rules.v4


echo "Настройка завершена! IP-forwarding включен, NAT настроен и сохранен."
