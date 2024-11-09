#!/bin/bash

# Переменные
SERVER_IP="31.15.18.222"
DNS1="1.1.1.1"
DNS2="9.9.9.9"
PROFILE_DIR="/root/vpnprofiles"
OPENVPN_CONF="/etc/openvpn/server.conf"
EASYRSA_DIR="/etc/openvpn/easy-rsa"
CERTS_DIR="/etc/openvpn/easy-rsa/pki"

# Удаляем старые конфигурации и ключи
echo "Удаление старых конфигураций и ключей OpenVPN..."
apt-get remove --purge -y openvpn easy-rsa
rm -rf /etc/openvpn/*
rm -rf $EASYRSA_DIR
rm -f /var/log/openvpn.log
rm -f /var/log/openvpn-status.log

# Устанавливаем необходимые пакеты
echo "Установка пакетов OpenVPN и Easy-RSA..."
apt-get update -y
apt-get install -y openvpn easy-rsa

# Создаем структуру для сертификатов
echo "Инициализация структуры Easy-RSA..."
make-cadir $EASYRSA_DIR
cd $EASYRSA_DIR
./easyrsa init-pki

# Создаем новый CA и сертификаты
echo "Создание CA и сертификатов для сервера..."
./easyrsa --batch build-ca nopass
./easyrsa --batch gen-req server nopass
./easyrsa --batch sign-req server server
./easyrsa gen-dh

# Перемещаем сертификаты в папку OpenVPN
cp $CERTS_DIR/ca.crt $CERTS_DIR/private/server.key $CERTS_DIR/issued/server.crt $CERTS_DIR/dh.pem /etc/openvpn/

# Создаем конфигурационный файл для OpenVPN сервера
echo "Создание конфигурационного файла OpenVPN..."
cat > $OPENVPN_CONF <<EOF
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
cipher AES-256-CBC
auth SHA256
keepalive 10 120
persist-key
persist-tun
user nobody
group nogroup
topology subnet
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS $DNS1"
push "dhcp-option DNS $DNS2"
explicit-exit-notify 1
log-append /var/log/openvpn.log
status /var/log/openvpn-status.log
verb 3
EOF

#Включаем IP-forwarding
echo "Включаем IP-forwarding..."
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
sysctl -p

# Включаем и запускаем OpenVPN
echo "Запуск OpenVPN..."
systemctl enable openvpn@server
systemctl start openvpn@server

echo "OpenVPN сервер настроен и запущен."
