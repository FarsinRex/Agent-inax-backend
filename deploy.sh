#!/bin/bash

# Flask App Deployment Script for AWS EC2
# This script sets up the Flask application on a fresh EC2 instance

set -e  # Exit on any error

echo "🚀 Starting Flask App Deployment on AWS EC2..."

# Update system packages
echo "📦 Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install Python 3.10 and pip
echo "🐍 Installing Python 3.10..."
sudo apt-get install -y python3.10 python3.10-venv python3.10-dev python3-pip

# Install nginx
echo "🌐 Installing nginx..."
sudo apt-get install -y nginx

# Install git
echo "📁 Installing git..."
sudo apt-get install -y git

# Create application directory
echo "📂 Creating application directory..."
sudo mkdir -p /var/www/flask-app
sudo chown -R $USER:$USER /var/www/flask-app

# Clone or copy your application code here
# Replace with your actual repository URL or copy method
echo "📋 Copying application code..."
# git clone https://github.com/yourusername/your-repo.git /var/www/flask-app
# OR copy files manually to /var/www/flask-app

# Create virtual environment
echo "🔧 Setting up Python virtual environment..."
cd /var/www/flask-app
python3.10 -m venv venv
source venv/bin/activate

# Install dependencies
echo "📚 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements-prod.txt

# Create environment file
echo "⚙️ Setting up environment configuration..."
sudo cp env.example /var/www/flask-app/.env
echo "⚠️  Please edit /var/www/flask-app/.env with your actual configuration values"

# Set up systemd service
echo "🔧 Setting up systemd service..."
sudo cp flask-app.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable flask-app

# Configure nginx
echo "🌐 Configuring nginx..."
sudo cp nginx.conf /etc/nginx/sites-available/flask-app
sudo ln -sf /etc/nginx/sites-available/flask-app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
sudo nginx -t

# Start services
echo "🚀 Starting services..."
sudo systemctl start flask-app
sudo systemctl restart nginx

# Enable firewall
echo "🔥 Configuring firewall..."
sudo ufw allow 'Nginx Full'
sudo ufw allow ssh
sudo ufw --force enable

echo "✅ Deployment completed successfully!"
echo "🌐 Your Flask app should be accessible at: http://your-ec2-public-ip"
echo "📝 Don't forget to:"
echo "   1. Edit /var/www/flask-app/.env with your actual configuration"
echo "   2. Restart the service: sudo systemctl restart flask-app"
echo "   3. Check logs: sudo journalctl -u flask-app -f"
