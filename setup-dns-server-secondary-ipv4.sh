#!/bin/bash

#########################################################################################
# DANIEL S. FIGUEIRÓ                                                                    #
# IT CONSULTANT                                                                         #
# LINKEDIN: https://www.linkedin.com/in/danielselbachtech/                              #
# SCRIPT V.: 1.0 - BIND9                                                                #
#########################################################################################

# Check root permissions
echo "[+] Checking for root permissions"
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root"
    exit 1
fi

# Requesting information from the user
read -p "Enter your server IP: " SERVER_IP
read -p "Enter your domain (e.g., example.com): " DOMAIN
read -p "Enter the reverse zone (e.g., 30.200.10): " REVERSE_ZONE
read -p "Enter the forwarder 1 IP: " FORWARDER_1_IP
read -p "Enter the forwarder 2 IP: " FORWARDER_2_IP
read -p "Enter the serial number (e.g., 2024072301): " SERIAL_NUMBER
read -p "Enter the last octet of the reverse IP: " LAST_OCTET
read -p "Enter the IP of the master DNS server: " MASTER_SERVER_IP

# Update package lists
echo "[+] Updating package lists"
apt-get update

# Install BIND9
echo "[+] Installing BIND 9"
apt-get install -y bind9 bind9utils bind9-doc

# Configure BIND9
echo "[+] Configuring BIND 9"

# Backup original configuration files
cp /etc/bind/named.conf /etc/bind/named.conf.backup
cp /etc/bind/named.conf.local /etc/bind/named.conf.local.backup
cp /etc/bind/named.conf.options /etc/bind/named.conf.options.backup

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
};
EOF

# Configure named.conf.local
cat > /etc/bind/named.conf.local <<EOF
zone "$DOMAIN" {
    type slave;
    masters { $MASTER_SERVER_IP; }; # Replace with your master server IP
    file "db.$DOMAIN";
};

zone "$REVERSE_ZONE.in-addr.arpa" {
    type slave;
    masters { $MASTER_SERVER_IP; }; # Replace with your master server IP
    file "db.$REVERSE_ZONE";
};
EOF

# Verify BIND configuration
echo "[+] Checking BIND configuration"
named-checkconf

# Restart the NAMED service
echo "[+] Restarting NAMED service"
systemctl restart named.service

# Enable NAMED service
echo "[+] Enabling NAMED service"
systemctl enable named.service

# Configure resolv.conf
sed -i '/IP\|domain\|search\|nameserver/d' /etc/resolv.conf
echo "search 127.0.0.1" | tee -a /etc/resolv.conf
echo "nameserver 127.0.0.1" | tee -a /etc/resolv.conf
chattr +i /etc/resolv.conf

echo "####################################################################"
echo "## Secondary DNS Server configuration complete.                   ##"
echo "## Ensure you adjust your firewall settings to allow DNS traffic. ##"
echo "## Test your DNS server with tools like dig or nslookup.          ##"
echo "####################################################################"
