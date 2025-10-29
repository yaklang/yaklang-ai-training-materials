#!/bin/bash

# Colors for output
# For log more
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function for colored echo
print_message() {
    local type=$1
    local message=$2
    case $type in
        "info") echo -e "${YELLOW}[INFO]${NC} $message" ;;
        "success") echo -e "${GREEN}[SUCCESS]${NC} $message" ;;
        "error") echo -e "${RED}[ERROR]${NC} $message" ;;
    esac
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --domain DOMAIN     Domain name (e.g., example.com)"
    echo "  --port PORT         Local service port (1-65535)"
    echo "  --email EMAIL       Email for SSL notifications"
    echo "  -y, --yes          Auto-confirm all prompts (non-interactive mode)"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --domain health.yaklang.com --port 9901 --email admin@example.com -y"
    echo "  $0 --domain example.com --port 8080 --email user@example.com"
    echo ""
}

# Initialize variables
domain=""
port=""
email=""
auto_confirm=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --domain)
            domain="$2"
            shift 2
            ;;
        --port)
            port="$2"
            shift 2
            ;;
        --email)
            email="$2"
            shift 2
            ;;
        -y|--yes)
            auto_confirm=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_message "error" "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Interactive mode if parameters not provided
if [[ -z "$domain" ]]; then
    if [[ "$auto_confirm" == true ]]; then
        print_message "error" "Domain is required in non-interactive mode. Use --domain option."
        exit 1
    fi
    read -p "[?] Please enter domain name (e.g., example.com): " domain
fi

if [[ -z "$port" ]]; then
    if [[ "$auto_confirm" == true ]]; then
        print_message "error" "Port is required in non-interactive mode. Use --port option."
        exit 1
    fi
    read -p "[?] Please enter local service port (1-65535): " port
fi

# Validate domain format (supports subdomains)
if [[ ! "$domain" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$ ]]; then
    print_message "error" "Invalid domain format: $domain"
    exit 1
fi

# Port validation
if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
    print_message "error" "Invalid port number: $port"
    exit 1
fi

print_message "info" "Configuration:"
print_message "info" "  Domain: $domain"
print_message "info" "  Port: $port"
print_message "info" "  Email: ${email:-'(will be requested)'}"
print_message "info" "  Auto-confirm: $auto_confirm"

# Check if port is in use
if ! nc -z localhost $port; then
    print_message "error" "Port $port is not responding. Please check if your service is running"
    if [[ "$auto_confirm" == false ]]; then
        read -p "Continue anyway? (y/n): " continue
        if [[ "$continue" != "y" && "$continue" != "Y" ]]; then
            exit 1
        fi
    else
        print_message "info" "Auto-confirm mode: continuing despite port not responding"
    fi
fi

# Check if certificate already exists
cert_path="/etc/nginx/ssl/$domain"
if [ -f "$cert_path/fullchain.pem" ] && [ -f "$cert_path/key.pem" ]; then
    print_message "info" "SSL certificate already exists for $domain"
    skip_cert=true
else
    skip_cert=false
    # Ask for installation only if cert doesn't exist
    if [[ "$auto_confirm" == false ]]; then
        read -p "[?] Do you want to install required components (acme.sh/nginx/cron)? (y/n): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            print_message "error" "Installation cancelled by user"
            exit 1
        fi
    else
        print_message "info" "Auto-confirm mode: installing required components"
    fi

    # Package manager detection and installation
    if command -v apt &> /dev/null; then
        print_message "info" "Debian/Ubuntu detected, using APT..."
        if [[ "$auto_confirm" == true ]]; then
            # Set non-interactive mode for apt
            export DEBIAN_FRONTEND=noninteractive
            sudo apt update -qq >/dev/null 2>&1
            sudo apt install -y nginx cron curl socat netcat-openbsd >/dev/null 2>&1
        else
            sudo apt update
            sudo apt install -y nginx cron curl socat netcat-openbsd
        fi
    elif command -v yum &> /dev/null; then
        print_message "info" "RHEL/CentOS detected, using YUM..."
        if [[ "$auto_confirm" == true ]]; then
            sudo yum install -y epel-release >/dev/null 2>&1
            sudo yum install -y nginx cronie curl socat nc >/dev/null 2>&1
        else
            sudo yum install -y epel-release
            sudo yum install -y nginx cronie curl socat nc
        fi
    elif command -v dnf &> /dev/null; then
        print_message "info" "Fedora detected, using DNF..."
        if [[ "$auto_confirm" == true ]]; then
            sudo dnf install -y nginx cron curl socat nc >/dev/null 2>&1
        else
            sudo dnf install -y nginx cron curl socat nc
        fi
    else
        print_message "error" "Unsupported package manager. Supported: apt, yum, dnf"
        exit 1
    fi

    # Get email and install acme.sh if needed
    if [[ -z "$email" ]]; then
        if [[ "$auto_confirm" == true ]]; then
            print_message "error" "Email is required in non-interactive mode. Use --email option."
            exit 1
        fi
        read -p "[?] Please enter your email for SSL notifications: " email
    fi
    
    # Validate email format
    if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        print_message "error" "Invalid email format"
        exit 1
    fi
    
    # Check if acme.sh is already installed
    if [ -f ~/.acme.sh/acme.sh ]; then
        print_message "info" "acme.sh is already installed, skipping installation"
    else
        print_message "info" "Installing acme.sh with email: $email"
        if [[ "$auto_confirm" == true ]]; then
            curl -s https://get.acme.sh | sh -s email=$email >/dev/null 2>&1
        else
            curl https://get.acme.sh | sh -s email=$email
        fi
    fi
    
    # Ensure acme.sh is in PATH
    if [ -f ~/.acme.sh/acme.sh ]; then
        export PATH="$HOME/.acme.sh:$PATH"
    else
        print_message "error" "acme.sh installation failed"
        exit 1
    fi

    # SSL certificate issuance
    print_message "info" "Checking existing certificates..."
    
    # Check if certificate already exists in acme.sh
    if ~/.acme.sh/acme.sh --list | grep -q "$domain"; then
        print_message "info" "Certificate for $domain already exists in acme.sh"
        # Try to renew if needed
        print_message "info" "Attempting to renew certificate if necessary..."
        ~/.acme.sh/acme.sh --renew -d $domain --force >/dev/null 2>&1 || {
            print_message "info" "Certificate renewal not needed or failed, continuing with existing certificate"
        }
    else
        print_message "info" "Issuing new SSL certificate for $domain..."
        
        # Stop nginx if running to avoid port conflicts
        if systemctl is-active nginx >/dev/null 2>&1; then
            print_message "info" "Stopping nginx for certificate issuance..."
            sudo systemctl stop nginx
            nginx_was_running=true
        else
            nginx_was_running=false
        fi
        
        # Issue certificate
        if ~/.acme.sh/acme.sh --issue --standalone -d $domain; then
            print_message "success" "Certificate issued successfully"
        else
            print_message "error" "Certificate issuance failed"
            # Restart nginx if it was running
            if [ "$nginx_was_running" = true ]; then
                sudo systemctl start nginx
            fi
            exit 1
        fi
        
        # Restart nginx if it was running
        if [ "$nginx_was_running" = true ]; then
            sudo systemctl start nginx
        fi
    fi

    # Certificate installation
    print_message "info" "Installing certificate to nginx directory..."
    sudo mkdir -p $cert_path
    
    # Install certificate (this is safe to run multiple times)
    if sudo ~/.acme.sh/acme.sh --install-cert -d $domain \
        --cert-file $cert_path/cert.pem \
        --key-file $cert_path/key.pem \
        --fullchain-file $cert_path/fullchain.pem; then
        print_message "success" "Certificate installed successfully"
    else
        print_message "error" "Certificate installation failed"
        exit 1
    fi

    # Set up auto-renewal (check if already exists)
    renewal_cron="0 0 * * 0 ~/.acme.sh/acme.sh --cron --home ~/.acme.sh && systemctl reload nginx"
    if ! crontab -l 2>/dev/null | grep -F "acme.sh --cron" >/dev/null; then
        print_message "info" "Setting up auto-renewal cron job..."
        (crontab -l 2>/dev/null; echo "$renewal_cron") | crontab -
        print_message "success" "Auto-renewal cron job added"
    else
        print_message "info" "Auto-renewal cron job already exists"
    fi
fi

# Generate Nginx configuration
config_file="/etc/nginx/sites-available/$domain.conf"
print_message "info" "Generating Nginx configuration for $domain..."

# Backup existing configuration if it exists
if [ -f "$config_file" ]; then
    print_message "info" "Backing up existing configuration..."
    sudo cp "$config_file" "$config_file.backup.$(date +%Y%m%d_%H%M%S)"
fi

sudo tee $config_file > /dev/null <<EOL
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $domain;

    # SSL Configuration
    ssl_certificate $cert_path/fullchain.pem;
    ssl_certificate_key $cert_path/key.pem;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    location / {
        proxy_pass http://127.0.0.1:$port;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # CORS headers
        if (\$request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE, PATCH';
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization';
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        }
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE, PATCH' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range' always;

        # WebSocket support
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

server {
    listen 80;
    listen [::]:80;
    server_name $domain;

    location / {
        proxy_pass http://127.0.0.1:$port;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # CORS headers
        if (\$request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE, PATCH';
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization';
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        }
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE, PATCH' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range' always;

        # WebSocket support
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOL

# Enable configuration
if [ -d "/etc/nginx/sites-enabled" ]; then
    print_message "info" "Enabling Nginx site configuration..."
    sudo ln -sf $config_file /etc/nginx/sites-enabled/
    print_message "success" "Nginx configuration enabled"
else
    print_message "info" "sites-enabled directory not found, configuration placed in sites-available only"
fi

# Create management script if it doesn't exist
if [ ! -f "/usr/local/bin/ssl-manager" ]; then
    sudo tee /usr/local/bin/ssl-manager > /dev/null <<'EOL'
#!/bin/bash
case "$1" in
    renew)
        ~/.acme.sh/acme.sh --cron --home ~/.acme.sh
        systemctl reload nginx
        ;;
    status)
        systemctl status nginx
        echo "SSL Certificate Status:"
        ~/.acme.sh/acme.sh --list
        ;;
    *)
        echo "Usage: ssl-manager [renew|status]"
        exit 1
        ;;
esac
EOL
    sudo chmod +x /usr/local/bin/ssl-manager
fi

# Test Nginx configuration and manage service
print_message "info" "Testing Nginx configuration..."
if sudo nginx -t 2>/dev/null; then
    print_message "success" "Nginx configuration test passed"
    
    if systemctl is-active nginx >/dev/null 2>&1; then
        print_message "info" "Reloading Nginx configuration..."
        if sudo systemctl reload nginx; then
            print_message "success" "Nginx reloaded successfully"
        else
            print_message "error" "Nginx reload failed"
            exit 1
        fi
    else
        print_message "info" "Starting Nginx service..."
        if sudo systemctl start nginx; then
            print_message "success" "Nginx started successfully"
        else
            print_message "error" "Nginx start failed"
            exit 1
        fi
    fi
    
    # Enable nginx to start on boot
    if ! systemctl is-enabled nginx >/dev/null 2>&1; then
        print_message "info" "Enabling Nginx to start on boot..."
        sudo systemctl enable nginx >/dev/null 2>&1
    fi
else
    print_message "error" "Nginx configuration test failed"
    sudo nginx -t  # Show the actual error
    exit 1
fi

print_message "success" "Deployment completed!"
if [ "$skip_cert" = false ]; then
    print_message "info" "Auto-renewal task has been added"
fi
print_message "info" "Please ensure:"
echo "1. Domain DNS is properly configured to point to this server's IP"
echo "2. Firewall ports 80 and 443 are open"
echo "3. Local service is running on port $port"
echo ""
print_message "info" "Management commands:"
echo "- Check status: ssl-manager status"
echo "- Manual renewal: ssl-manager renew"

