#!/bin/bash

CLIENT_NAME=$1
PROFILE_DIR="/root/vpnprofiles"
SERVER_IP="31.15.18.222"
EASYRSA_DIR="/etc/openvpn/easy-rsa"

mkdir /root/vpnprofiles

if [[ -z "$CLIENT_NAME" ]]; then
    echo "Необходимо указать имя клиента. Использование: ./generate_client_config.sh <имя_клиента>"
    exit 1
fi

# Генерация ключей и сертификатов клиента
cd $EASYRSA_DIR
./easyrsa --batch gen-req "$CLIENT_NAME" nopass
./easyrsa --batch sign-req client "$CLIENT_NAME"

# Создание конфигурационного файла клиента
CLIENT_CONF="$PROFILE_DIR/$CLIENT_NAME.ovpn"
cat > "$CLIENT_CONF" <<EOF
client
dev tun
proto udp
remote $SERVER_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
auth-nocache
verb 3

<ca>
$(cat /etc/openvpn/easy-rsa/pki/ca.crt)
</ca>

<cert>
$(cat /etc/openvpn/easy-rsa/pki/issued/$CLIENT_NAME.crt)
</cert>

<key>
$(cat /etc/openvpn/easy-rsa/pki/private/$CLIENT_NAME.key)
</key>
EOF

echo "Клиентский профиль $CLIENT_NAME создан в $CLIENT_CONF."
