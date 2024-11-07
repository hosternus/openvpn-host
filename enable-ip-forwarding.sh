#!/bin/bash

# Включение IP-forwarding
echo "Включаем IP-forwarding..."
echo 1 > /proc/sys/net/ipv4/ip_forward

# Проверка и добавление строки для постоянного включения IP-forwarding
echo "Добавляем IP-forwarding в sysctl.conf для постоянного включения..."
if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
else
    echo "IP-forwarding уже включен в sysctl.conf"
fi

# Применение изменений sysctl
sysctl -p

# Определение сетевого интерфейса, через который сервер подключен к Интернету
INTERFACE=$(ip route | grep default | awk '{print $5}')
echo "Используем интерфейс: $INTERFACE"

# Настройка NAT для выхода трафика в Интернет
echo "Настраиваем NAT с использованием iptables..."
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o "$INTERFACE" -j MASQUERADE

# Установка пакета iptables-persistent для сохранения правил
echo "Устанавливаем iptables-persistent для сохранения правил NAT..."
apt-get update -y
apt-get install -y iptables-persistent

# Сохранение правил iptables для загрузки при старте системы
echo "Сохраняем правила iptables..."
iptables-save > /etc/iptables/rules.v4

echo "Настройка завершена! IP-forwarding включен, NAT настроен и сохранен."
