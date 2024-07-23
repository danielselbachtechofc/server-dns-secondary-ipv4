#!/bin/bash

#########################################################################################
# DANIEL S. FIGUEIRÓ                                                                    #
# NETWORK SPECIALIST                                                                    #
# E-MAIL: danielselbach.fig@gmail.com                                                   #
# Script V.: 1.0 - BIND9                                                                #
#########################################################################################

echo "[+] Checking for root permissions"
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root"
    exit 1
fi

# Prompting the user for information
read -p "Enter your server IP: " SERVER_IP
read -p "Enter your domain (e.g., flashtech.local): " DOMAIN
read -p "Enter the forwarder 1 IP: " FORWARDER_1_IP
read -p "Enter the forwarder 2 IP: " FORWARDER_2_IP
read -p "Enter the serial number (e.g., 2024072301): " SERIAL_NUMBER
read -p "Enter the reverse zone (e.g., 30.200.10): " REVERSE_ZONE
read -p "Enter the IP of the master DNS server: " MASTER_DNS

echo "[+] Updating package lists"
apt-get update

echo "[+] Installing BIND 9"
apt-get install -y bind9 bind9utils bind9-doc

echo "[+] Configuring BIND 9"
# Backup original configuration files
cp /etc/bind/named.conf /etc/bind/named.conf.bak
cp /etc/bind/named.conf.local /etc/bind/named.conf.local.bak
cp /etc/bind/named.conf.options /etc/bind/named.conf.options.bak

# Configure named.conf.options
cat > /etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";

    recursion yes; # Enable recursion
    allow-recursion { any; }; # Allow recursion from any client

    dnssec-validation no; # Disable DNSSEC validation

    auth-nxdomain no; # Disable authoritative responses for non-existent domains
    listen-on { 127.0.0.1; $SERVER_IP; };
    listen-on-v6 { any; };

    forwarders {
        $FORWARDER_1_IP;
        $FORWARDER_2_IP;
    };

    allow-transfer { $MASTER_DNS; };
};
EOF

# Configure named.conf.local
cat > /etc/bind/named.conf.local <<EOF
zone "$DOMAIN" {
    type slave;
    file "/var/cache/bind/db.$DOMAIN";
    masters { $MASTER_DNS; };
};

zone "$REVERSE_ZONE.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.$REVERSE_ZONE";
    masters { $MASTER_DNS; };
};
EOF

# Set permissions for cache directory
chown bind:bind /var/cache/bind
chmod 755 /var/cache/bind

echo "[+] Checking BIND configuration"
named-checkconf

echo "[+] Restarting BIND service"
systemctl restart bind9
systemctl enable bind9

echo "###################################################################"
echo "## Secondary DNS Server configuration complete.                  ##"
echo "## Ensure you adjust your firewall settings to allow DNS traffic. ##"
echo "## Test your DNS server with tools like dig or nslookup.          ##"
echo "###################################################################"
