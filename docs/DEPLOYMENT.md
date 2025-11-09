# OpenEdge Dynamic Data Masking - Deployment Guide

## Overview

This guide provides step-by-step instructions for deploying the OpenEdge Dynamic Data Masking solution in various environments.

## Prerequisites

- OpenEdge 12.8+ with valid license
- PASOE (Progress Application Server for OpenEdge)
- Node.js 16+ (for web UI)
- Database connectivity (sports2020 or custom database)

## Development Environment Setup

### 1. DevContainer Setup (Recommended)

```bash
# Clone repository
git clone https://github.com/your-org/oe_ddm.git
cd oe_ddm

# Copy your OpenEdge license
cp /path/to/progress.cfg license/

# Open in VS Code with Dev Containers extension
code .
# Run: "Dev Containers: Reopen in Container"
```

### 2. Manual Setup

```bash
# Set OpenEdge environment
export DLC=/usr/dlc
export PATH=$DLC/bin:$PATH

# Compile ABL classes
cd src
_progres -p compile-all.p

# Start database (if using sports2020)
_mprosrv sports2020 -S 10000 -H localhost
```

## Production Deployment

### 1. PASOE Instance Creation

```bash
# Create new PASOE instance
$DLC/bin/tcman.sh create -t oepas1 ddm-production -p 8080 -P 8443

# Set environment variables
export CATALINA_BASE=/path/to/ddm-production
export CATALINA_HOME=$DLC/servers/pasoe
```

### 2. Configure PASOE

```bash
# Copy configuration files
cp conf/openedge.properties $CATALINA_BASE/conf/
cp conf/masking-config.json $CATALINA_BASE/conf/

# Deploy ABL source code
mkdir -p $CATALINA_BASE/webapps/ROOT/WEB-INF/openedge/src
cp -r src/* $CATALINA_BASE/webapps/ROOT/WEB-INF/openedge/src/

# Set PROPATH in openedge.properties
echo "OEABL.propath=$CATALINA_BASE/webapps/ROOT/WEB-INF/openedge/src,\$DLC/tty,\$DLC/tty/netlib/OpenEdge.Net.pl" >> $CATALINA_BASE/conf/openedge.properties
```

### 3. Database Configuration

```bash
# Create production database
prodb create ddm-prod empty

# Start database broker
_mprosrv ddm-prod -S 20000 -H localhost -n 50

# Update database connection in openedge.properties
echo "database.ddm.connect=-db ddm-prod -S 20000 -H localhost" >> $CATALINA_BASE/conf/openedge.properties
```

### 4. Start PASOE

```bash
# Start the PASOE instance
$DLC/bin/tcman.sh start ddm-production

# Verify startup
curl http://localhost:8080/api/masking/health
```

## Web UI Deployment

### 1. Build React Application

```bash
cd web

# Install dependencies
npm install

# Build for production
npm run build
```

### 2. Deploy to Web Server

#### Option A: Nginx

```bash
# Copy build files
sudo cp -r build/* /var/www/ddm-admin/

# Nginx configuration
sudo tee /etc/nginx/sites-available/ddm-admin << EOF
server {
    listen 80;
    server_name ddm-admin.yourdomain.com;
    root /var/www/ddm-admin;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://localhost:8080/api/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Enable site
sudo ln -s /etc/nginx/sites-available/ddm-admin /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

#### Option B: Apache

```bash
# Copy build files
sudo cp -r build/* /var/www/html/ddm-admin/

# Apache configuration
sudo tee /etc/apache2/sites-available/ddm-admin.conf << EOF
<VirtualHost *:80>
    ServerName ddm-admin.yourdomain.com
    DocumentRoot /var/www/html/ddm-admin
    
    <Directory /var/www/html/ddm-admin>
        Options -Indexes
        AllowOverride All
        Require all granted
    </Directory>
    
    ProxyPass /api/ http://localhost:8080/api/
    ProxyPassReverse /api/ http://localhost:8080/api/
</VirtualHost>
EOF

# Enable site
sudo a2ensite ddm-admin
sudo systemctl reload apache2
```

## Security Configuration

### 1. HTTPS Setup

```bash
# Generate SSL certificate (Let's Encrypt example)
sudo certbot --nginx -d ddm-admin.yourdomain.com

# Or use existing certificates
sudo cp /path/to/certificate.crt /etc/ssl/certs/
sudo cp /path/to/private.key /etc/ssl/private/
```

### 2. PASOE Security

```bash
# Enable HTTPS in PASOE
echo "server.ssl.enabled=true" >> $CATALINA_BASE/conf/openedge.properties
echo "server.ssl.keystore=/path/to/keystore.jks" >> $CATALINA_BASE/conf/openedge.properties
echo "server.ssl.keystore-password=your-password" >> $CATALINA_BASE/conf/openedge.properties
```

### 3. Database Security

```bash
# Create secure database user
echo "CREATE USER ddm_api PASSWORD 'secure_password';" | _progres -db ddm-prod -p

# Grant appropriate permissions
echo "GRANT SELECT, UPDATE ON Customer TO ddm_api;" | _progres -db ddm-prod -p
```

## Environment-Specific Configurations

### Development

```bash
# Use local database
export DB_CONNECTION="-db sports2020 -S 10000 -H localhost"

# Enable debug logging
echo "log4j.rootCategory=DEBUG, CONSOLE" >> conf/openedge.properties
```

### Staging

```bash
# Use staging database
export DB_CONNECTION="-db ddm-staging -S 20000 -H staging-db"

# Moderate logging
echo "log4j.rootCategory=INFO, FILE" >> conf/openedge.properties
```

### Production

```bash
# Use production database with failover
export DB_CONNECTION="-db ddm-prod -S 20000 -H prod-db-primary -S2 prod-db-secondary"

# Minimal logging for performance
echo "log4j.rootCategory=WARN, FILE" >> conf/openedge.properties
```

## Monitoring and Health Checks

### 1. Application Monitoring

```bash
# Health check script
#!/bin/bash
HEALTH_URL="http://localhost:8080/api/masking/health"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $HEALTH_URL)

if [ $RESPONSE -eq 200 ]; then
    echo "DDM API is healthy"
    exit 0
else
    echo "DDM API is unhealthy (HTTP $RESPONSE)"
    exit 1
fi
```

### 2. Log Monitoring

```bash
# Monitor PASOE logs
tail -f $CATALINA_BASE/logs/catalina.out

# Monitor application logs
tail -f $CATALINA_BASE/logs/ddm-application.log
```

### 3. Database Monitoring

```bash
# Check database connections
_progres -db ddm-prod -p monitor-connections.p

# Monitor performance
_progres -db ddm-prod -p performance-stats.p
```

## Backup and Recovery

### 1. Database Backup

```bash
# Create database backup
probkup online ddm-prod /backup/ddm-prod-$(date +%Y%m%d).bak

# Automated backup script
#!/bin/bash
BACKUP_DIR="/backup/ddm"
DATE=$(date +%Y%m%d_%H%M%S)
probkup online ddm-prod $BACKUP_DIR/ddm-prod-$DATE.bak
find $BACKUP_DIR -name "*.bak" -mtime +7 -delete
```

### 2. Configuration Backup

```bash
# Backup configuration files
tar -czf /backup/ddm-config-$(date +%Y%m%d).tar.gz \
    conf/ \
    $CATALINA_BASE/conf/openedge.properties \
    $CATALINA_BASE/webapps/ROOT/WEB-INF/openedge/
```

## Troubleshooting

### Common Issues

1. **PASOE Won't Start**
   ```bash
   # Check logs
   tail -f $CATALINA_BASE/logs/catalina.out
   
   # Verify Java version
   java -version
   
   # Check port availability
   netstat -tulpn | grep 8080
   ```

2. **Database Connection Issues**
   ```bash
   # Test database connection
   _progres -db ddm-prod -S 20000 -H localhost -p test-connection.p
   
   # Check database broker
   _mprshut ddm-prod -by
   _mprosrv ddm-prod -S 20000 -H localhost
   ```

3. **API Returns 500 Errors**
   ```bash
   # Check ABL compilation
   cd src
   _progres -p compile-check.p
   
   # Verify PROPATH
   echo $PROPATH
   ```

### Performance Tuning

```bash
# Increase PASOE memory
echo "CATALINA_OPTS=\"-Xmx2g -Xms1g\"" >> $CATALINA_BASE/bin/setenv.sh

# Database performance tuning
echo "-B 50000 -spin 2000000" >> ddm-prod.pf

# Connection pooling
echo "database.ddm.maxConnections=20" >> $CATALINA_BASE/conf/openedge.properties
```

## Maintenance

### Regular Tasks

1. **Weekly**
   - Review audit logs
   - Check system performance
   - Verify backups

2. **Monthly**
   - Update security patches
   - Review configuration changes
   - Performance optimization

3. **Quarterly**
   - Security audit
   - Disaster recovery testing
   - Capacity planning

### Upgrade Procedures

```bash
# 1. Backup current system
./backup-system.sh

# 2. Stop services
$DLC/bin/tcman.sh stop ddm-production

# 3. Deploy new version
cp -r new-version/src/* $CATALINA_BASE/webapps/ROOT/WEB-INF/openedge/src/

# 4. Update configuration if needed
# 5. Start services
$DLC/bin/tcman.sh start ddm-production

# 6. Verify deployment
curl http://localhost:8080/api/masking/health
```
