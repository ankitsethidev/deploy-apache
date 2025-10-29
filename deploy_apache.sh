#!/bin/bash
# ==========================================================
# Script: deploy_apache.sh
# Purpose: Install and configure Apache Web Server
# Author: Your Name
# Usage: bash deploy_apache.sh
# ==========================================================

set -e  # Exit immediately on error

# ---- Detect OS and install Apache ----
echo "[INFO] Detecting operating system..."
if command -v apt-get &>/dev/null; then
    echo "[INFO] Installing Apache on Ubuntu/Debian..."
    sudo apt-get update -y
    sudo apt-get install -y apache2
    APACHE_SERVICE="apache2"
elif command -v yum &>/dev/null; then
    echo "[INFO] Installing Apache on Amazon Linux/CentOS..."
    sudo yum update -y
    sudo yum install -y httpd
    APACHE_SERVICE="httpd"
else
    echo "[ERROR] Unsupported OS. Exiting..."
    exit 1
fi

# ---- Enable and start Apache service ----
echo "[INFO] Enabling and starting Apache service..."
sudo systemctl enable $APACHE_SERVICE
sudo systemctl start $APACHE_SERVICE

# ---- Create a default web page ----
WEB_DIR="/var/www/html"
echo "[INFO] Creating default web page..."
sudo bash -c "cat > $WEB_DIR/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apache Server Deployed</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f7f7f7; text-align: center; padding-top: 50px; }
        h1 { color: #e44d26; }
        p { color: #333; }
    </style>
</head>
<body>
    <h1>🚀 Apache Server is Running Successfully!</h1>
    <p>This web server was deployed automatically using a Bash script.</p>
</body>
</html>
EOF

# ---- Adjust firewall (if available) ----
if command -v ufw &>/dev/null; then
    echo "[INFO] Allowing HTTP (80) and HTTPS (443) traffic..."
    sudo ufw allow 'Apache Full' || true
elif command -v firewall-cmd &>/dev/null; then
    echo "[INFO] Configuring firewall for Apache..."
    sudo firewall-cmd --permanent --add-service=http || true
    sudo firewall-cmd --permanent --add-service=https || true
    sudo firewall-cmd --reload || true
fi

# ---- Restart to apply all changes ----
echo "[INFO] Restarting Apache service..."
sudo systemctl restart $APACHE_SERVICE

# ---- Show service status ----
echo "[INFO] Checking Apache status..."
sudo systemctl status $APACHE_SERVICE --no-pager

# ---- Print server information ----
echo "=========================================================="
echo "[SUCCESS] Apache Web Server deployed successfully!"
echo "Access it in your browser at: http://$(curl -s ifconfig.me)"
echo "Document Root: $WEB_DIR"
echo "=========================================================="
