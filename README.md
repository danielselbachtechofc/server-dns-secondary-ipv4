## DNS Server Setup Script
This script sets up a secondary DNS server using BIND 9 on Debian 12. It configures the server to act as a slave for specified zones.

## Usage
Replace placeholders in `setup-dns-server-secondary.sh` with your actual server details:

`[YOUR_SERVER_IP]`
`[YOUR_DOMAIN]`
`[REVERSE_ZONE]`
`[FORWARDER_1_IP]`
`[FORWARDER_2_IP]`
`[SERIAL_NUMBER]`
`[LAST_OCTET]`
`[MASTER_SERVER_IP]`

## Steps:

1. Clone the repository and navigate to the directory:
`git clone https://github.com/danielselbachtechofc/server-dns-secondary-ipv4.git`
`cd server-dns-secondary-ipv4`

2. Make the script executable:
`chmod +x setup-dns-server-secondary.sh`

3. Run the script as root:
`sudo ./setup-dns-server-secondary.sh`

4. Verify the DNS server is working:
`nslookup google.com 127.0.0.1`
`nslookup ns.[YOUR_DOMAIN] 127.0.0.1`

## Notes
Ensure your firewall settings allow DNS traffic on port 53.
Modify the zone files and configurations as necessary to suit your environment.
