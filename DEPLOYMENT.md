# Flask App Deployment Guide for AWS EC2

This guide will help you deploy your Flask chatbot application to AWS EC2.

## Prerequisites

- AWS EC2 instance (Ubuntu 20.04 or 22.04 recommended)
- Domain name (optional, for production)
- Groq API key
- SSH access to your EC2 instance

## Deployment Options

### Option 1: Direct Deployment (Recommended for Production)

1. **Launch EC2 Instance**
   - Choose Ubuntu 20.04 or 22.04 LTS
   - Select appropriate instance type (t3.micro for testing, t3.small+ for production)
   - Configure security group to allow HTTP (80), HTTPS (443), and SSH (22)
   - Launch and connect via SSH

2. **Upload Your Code**
   ```bash
   # From your local machine, upload the code
   scp -r . ubuntu@your-ec2-ip:/home/ubuntu/flask-app
   ```

3. **Run Deployment Script**
   ```bash
   # On your EC2 instance
   cd /home/ubuntu/flask-app
   chmod +x deploy.sh
   ./deploy.sh
   ```

4. **Configure Environment**
   ```bash
   # Edit the environment file
   sudo nano /var/www/flask-app/.env
   ```
   
   Add your configuration:
   ```
   FLASK_ENV=production
   SECRET_KEY=your-very-secure-secret-key-here
   PORT=5000
   GROQ_API_KEY=your-groq-api-key-here
   ```

5. **Restart Services**
   ```bash
   sudo systemctl restart flask-app
   sudo systemctl restart nginx
   ```

### Option 2: Docker Deployment

1. **Install Docker on EC2**
   ```bash
   sudo apt-get update
   sudo apt-get install -y docker.io docker-compose
   sudo usermod -aG docker ubuntu
   # Log out and back in
   ```

2. **Deploy with Docker Compose**
   ```bash
   # Upload your code to EC2
   scp -r . ubuntu@your-ec2-ip:/home/ubuntu/flask-app
   
   # On EC2 instance
   cd /home/ubuntu/flask-app
   cp env.example .env
   # Edit .env with your configuration
   nano .env
   
   # Start the application
   docker-compose up -d
   ```

## Configuration Files

### Environment Variables (.env)
```bash
FLASK_ENV=production
SECRET_KEY=your-secret-key
PORT=5000
GROQ_API_KEY=your-groq-api-key
```

### Nginx Configuration
The nginx configuration includes:
- Reverse proxy to Flask app
- Security headers
- Gzip compression
- Logging

### Systemd Service
The Flask app runs as a systemd service for:
- Automatic startup on boot
- Process management
- Logging integration

## Security Considerations

1. **Firewall Configuration**
   ```bash
   sudo ufw allow 'Nginx Full'
   sudo ufw allow ssh
   sudo ufw enable
   ```

2. **SSL Certificate (Optional but Recommended)**
   ```bash
   # Install Certbot
   sudo apt-get install -y certbot python3-certbot-nginx
   
   # Get SSL certificate
   sudo certbot --nginx -d your-domain.com
   ```

3. **Update Security Groups**
   - Only allow necessary ports (22, 80, 443)
   - Restrict SSH access to your IP if possible

## Monitoring and Logs

### Check Application Status
```bash
# Check if Flask app is running
sudo systemctl status flask-app

# Check nginx status
sudo systemctl status nginx
```

### View Logs
```bash
# Flask app logs
sudo journalctl -u flask-app -f

# Nginx logs
sudo tail -f /var/log/nginx/flask-app.access.log
sudo tail -f /var/log/nginx/flask-app.error.log
```

### Application Logs
```bash
# If using Docker
docker-compose logs -f flask-app
```

## Troubleshooting

### Common Issues

1. **Port 5000 not accessible**
   - Check if the Flask app is running: `sudo systemctl status flask-app`
   - Check firewall: `sudo ufw status`
   - Check nginx configuration: `sudo nginx -t`

2. **API Key not working**
   - Verify the GROQ_API_KEY in your .env file
   - Check if the environment variable is loaded: `sudo systemctl show flask-app --property=Environment`

3. **Permission issues**
   - Ensure proper ownership: `sudo chown -R ubuntu:www-data /var/www/flask-app`
   - Check file permissions: `ls -la /var/www/flask-app`

### Performance Optimization

1. **Increase Gunicorn Workers**
   Edit `/etc/systemd/system/flask-app.service`:
   ```
   ExecStart=/var/www/flask-app/venv/bin/gunicorn --workers 8 --bind unix:/var/www/flask-app/flask-app.sock -m 007 app:app
   ```

2. **Enable Nginx Caching**
   Add to nginx.conf:
   ```
   location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
       expires 1y;
       add_header Cache-Control "public, immutable";
   }
   ```

## Maintenance

### Update Application
```bash
# Pull latest code
cd /var/www/flask-app
git pull origin main  # or your main branch

# Restart services
sudo systemctl restart flask-app
```

### Backup
```bash
# Backup application files
tar -czf flask-app-backup-$(date +%Y%m%d).tar.gz /var/www/flask-app

# Backup nginx configuration
sudo cp /etc/nginx/sites-available/flask-app /var/www/flask-app/nginx-backup.conf
```

## Production Checklist

- [ ] Environment variables configured
- [ ] SSL certificate installed (if using domain)
- [ ] Firewall configured
- [ ] Monitoring set up
- [ ] Backup strategy implemented
- [ ] Log rotation configured
- [ ] Security headers enabled
- [ ] Performance optimized

Your Flask chatbot app should now be running on AWS EC2! 🚀
