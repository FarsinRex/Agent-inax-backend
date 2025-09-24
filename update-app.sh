#!/bin/bash

# Update script for Flask App on AWS EC2
# This script updates the application with new code

set -e

echo "🔄 Updating Flask App..."

# Navigate to application directory
cd /var/www/flask-app

# Activate virtual environment
source venv/bin/activate

# Pull latest code (if using git)
# git pull origin main

# Or copy new files manually
# scp -r . ubuntu@your-ec2-ip:/var/www/flask-app

# Install/update dependencies
echo "📚 Updating dependencies..."
pip install -r requirements-prod.txt

# Restart the application
echo "🔄 Restarting Flask app..."
sudo systemctl restart flask-app

# Check status
echo "✅ Checking application status..."
sudo systemctl status flask-app --no-pager

echo "🎉 Update completed successfully!"
echo "🌐 Your app should be running at: http://your-ec2-ip"
