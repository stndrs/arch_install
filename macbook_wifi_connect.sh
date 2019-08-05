# For use before running install.sh on Macbook Pro 11, 4 (15 inch mid 2015)

# Check interface
# $ ip link set wlp3s0 up

printf "Enter the SSID to connect to: "
read -r SSID
printf "Enter the password for the selected network: "
read -r PASS

wpa_passphrase "$SSID" "$PASS" > /etc/wpa_supplicant/wpa.conf

# Check the connection
# wpa_supplicant -c /etc/wpa_supplicant/wpa.conf -i wlp3s0

wpa_supplicant -B -c /etc/wpa_supplicant/wpa.conf -i wlp3s0
dhclient wlp3s0