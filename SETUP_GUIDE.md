# Odoo Community Edition Setup Guide

This guide provides step-by-step instructions for setting up Odoo Community Edition with all official modules using Docker.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Starting Odoo](#starting-odoo)
- [Database Creation](#database-creation)
- [Installing Official Modules](#installing-official-modules)
- [Configuration](#configuration)
- [Backup and Restore](#backup-and-restore)
- [Troubleshooting](#troubleshooting)
- [Module List](#module-list)

## Prerequisites

### System Requirements
- **macOS** (Intel or Apple Silicon)
- **RAM**: Minimum 8GB (16GB recommended)
- **Storage**: 20GB free space
- **Docker Desktop** installed and running

### Installing Docker Desktop
1. Download Docker Desktop from https://www.docker.com/products/docker-desktop
2. Install Docker Desktop
3. Start Docker Desktop
4. Verify installation:
   ```bash
   docker --version
   docker-compose --version
   ```

## Initial Setup

### 1. Clone or Download Project
```bash
cd /path/to/your/projects
git clone [repository-url] odoo_community
cd odoo_community
```

### 2. Configure Environment
```bash
# Copy environment template
cp .env.example .env

# Edit .env file with your settings
nano .env
```

**Important .env settings:**
- `POSTGRES_PASSWORD`: Database password
- `ODOO_MASTER_PASSWORD`: Odoo master password (for database management)
- `SMTP_*`: Email settings (optional)

### 3. Update Odoo Configuration
```bash
# Edit Odoo configuration
nano config/odoo.conf
```

**Key settings to change:**
- `admin_passwd`: Change from default `ChangeMeToSecurePassword`
- `smtp_*`: Email server settings if needed

## Starting Odoo

### First Time Start
```bash
# Make scripts executable (first time only)
chmod +x scripts/*.sh

# Start Odoo services
./scripts/start.sh
```

The script will:
1. Check Docker is running
2. Create .env if missing
3. Start PostgreSQL and Odoo containers
4. Wait for services to be ready
5. Display access information

### Accessing Odoo
- **URL**: http://localhost:8069
- **Port**: 8069 (can be changed in docker-compose.yml)

## Database Creation

### First Database Setup
1. Open http://localhost:8069 in your browser
2. You'll see the database creation screen
3. Fill in the following:
   - **Master Password**: Use the password from `config/odoo.conf` (admin_passwd)
   - **Database Name**: e.g., `odoo_production` or `odoo_dev`
   - **Email**: Admin user email
   - **Password**: Admin user password
   - **Language**: Select your preferred language
   - **Country**: Select your country
   - **Demo Data**: 
     - ✅ Check for testing/development
     - ❌ Uncheck for production

4. Click "Create Database"
5. Wait for database creation (may take 1-2 minutes)

## Installing Official Modules

### Accessing the Apps Menu
1. After database creation, you'll be logged in automatically
2. Click on the **Apps** menu (grid icon)
3. Remove the "Apps" filter to see all available modules
4. You'll see all official Odoo Community Edition modules

### Core Business Modules

#### Sales & CRM
1. Search for "**CRM**"
2. Click Install
3. This will also install:
   - Sales
   - Contacts
   - Calendar

#### Inventory & Manufacturing
1. Install "**Inventory**"
2. Install "**Purchase**"
3. Install "**MRP**" (Manufacturing)
4. These work together for complete supply chain management

#### Accounting
1. Install "**Invoicing**" (Basic accounting in Community Edition)
2. Note: Full accounting is only in Enterprise Edition

#### Project Management
1. Install "**Project**"
2. Optionally install "**Timesheet**"

### Communication Modules

1. Install "**Discuss**" (Internal messaging)
2. Install "**Email Marketing**"
3. Install "**SMS Marketing**"
4. Install "**Live Chat**" (for website support)

### Human Resources Modules

1. Install "**Employees**"
2. Install "**Time Off**"
3. Install "**Recruitment**"
4. Install "**Attendances**"
5. Install "**Skills Management**"

### Website & E-commerce

1. Install "**Website**"
2. Install "**eCommerce**"
3. Install "**Blog**"
4. Install "**Events**"
5. Install "**eLearning**"
6. Install "**Forum**"

### Additional Tools

1. Install "**Maintenance**"
2. Install "**Fleet**"
3. Install "**Helpdesk**" (if available)
4. Install "**Surveys**"
5. Install "**Sign**" (Digital signatures)

### Module Installation Order
Some modules have dependencies. Recommended installation order:
1. **Contacts** (usually auto-installed)
2. **Sales/CRM**
3. **Inventory**
4. **Purchase**
5. **Employees**
6. **Website** (before eCommerce)
7. **Other modules** as needed

## Configuration

### Company Setup
1. Go to **Settings** → **General Settings**
2. Configure:
   - Company Name
   - Address
   - Logo
   - Currency
   - Timezone

### Email Configuration
1. Go to **Settings** → **General Settings** → **Discuss**
2. Configure Outgoing Email Server:
   - SMTP Server: smtp.gmail.com (example)
   - SMTP Port: 587
   - Security: TLS
   - Username: your-email@gmail.com
   - Password: app-specific password

### User Management
1. Go to **Settings** → **Users & Companies** → **Users**
2. Create users for your team
3. Assign appropriate access rights

### Multi-Company (if needed)
1. Go to **Settings** → **Users & Companies** → **Companies**
2. Create additional companies
3. Configure inter-company rules

## Backup and Restore

### Creating Backups
```bash
# Run backup script
./scripts/backup.sh
```

This creates:
- PostgreSQL database backup
- Odoo filestore backup
- Configuration files backup

Backups are stored in `backups/` directory with timestamps.

### Restoring from Backup
```bash
# List available backups
ls backups/

# Restore specific backup
./scripts/restore.sh 20240118_143022
```

### Automated Backups
Add to crontab for daily backups:
```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /path/to/odoo_community/scripts/backup.sh
```

## Troubleshooting

### Common Issues

#### Container Won't Start
```bash
# Check logs
docker-compose logs odoo
docker-compose logs db

# Restart services
./scripts/stop.sh
./scripts/start.sh
```

#### Database Connection Error
1. Check PostgreSQL is running: `docker-compose ps`
2. Verify credentials in `config/odoo.conf` match `.env`
3. Check PostgreSQL logs: `docker-compose logs db`

#### Permission Issues
```bash
# Fix permissions on data directories
sudo chown -R $(whoami):staff data/
```

#### Port Already in Use
```bash
# Find process using port 8069
lsof -i :8069

# Change port in docker-compose.yml if needed
```

### Viewing Logs
```bash
# All logs
docker-compose logs -f

# Odoo logs only
docker-compose logs -f odoo

# PostgreSQL logs only
docker-compose logs -f db
```

### Performance Tuning
1. Edit `config/odoo.conf`:
   - Increase `workers` for more concurrent users
   - Adjust `limit_memory_*` based on available RAM
2. Edit `docker-compose.yml`:
   - Increase PostgreSQL `shared_buffers`
   - Add more CPU/RAM limits if needed

## Module List

### Complete List of Official Community Edition Modules

#### Business Operations
- **Sales Management** - Quotations, Sales Orders, Customers
- **CRM** - Lead/Opportunity Management
- **Purchase Management** - Purchase Orders, Vendors
- **Inventory** - Warehouse Management, Stock Moves
- **MRP** - Manufacturing, Bill of Materials, Work Orders
- **Project** - Project Management, Tasks
- **Timesheet** - Time Tracking
- **Field Service** - Field Operations
- **Helpdesk** - Ticket Management
- **Point of Sale** - Retail POS System
- **Repairs** - Repair Order Management

#### Accounting & Finance
- **Invoicing** - Basic Invoicing (Community Edition)
- **Expenses** - Employee Expense Management

#### Human Resources
- **Employees** - Employee Directory
- **Recruitment** - Job Postings, Applications
- **Time Off** - Leave Management
- **Attendances** - Check In/Out
- **Skills Management** - Employee Skills Tracking
- **Employee Contracts** - Contract Management

#### Marketing
- **Email Marketing** - Mass Mailing Campaigns
- **SMS Marketing** - SMS Campaigns
- **Marketing Automation** - Automated Campaigns
- **Surveys** - Create and Send Surveys

#### Website
- **Website Builder** - Drag & Drop Website Creation
- **eCommerce** - Online Store
- **Blog** - Business Blog
- **Forum** - Community Forum
- **Slides** - eLearning Platform
- **Events** - Event Management & Registration
- **Live Chat** - Website Chat Support

#### Productivity
- **Discuss** - Internal Communication
- **Calendar** - Shared Calendar
- **Contacts** - Contact Management
- **Documents** - Document Management
- **Sign** - Electronic Signature
- **Notes** - Personal Notes
- **To-do** - Personal Task Management

#### Administration
- **Settings** - System Configuration
- **Users & Companies** - User Management
- **Technical** - Developer Tools

### Module Dependencies
Many modules have dependencies that are automatically installed:
- **CRM** requires: Sales, Calendar, Contacts
- **eCommerce** requires: Website, Inventory, Sales
- **MRP** requires: Inventory, Purchase
- **Employees** is base for all HR modules

## Next Steps

1. **Customize Odoo**:
   - Configure each installed module
   - Set up workflows
   - Create custom fields if needed

2. **Team Training**:
   - Use the quick start guide
   - Provide module-specific training
   - Create test environment for practice

3. **Production Preparation**:
   - Remove demo data
   - Configure proper backups
   - Set up SSL/HTTPS
   - Configure firewall rules

4. **Monitoring**:
   - Set up log monitoring
   - Configure alerts
   - Monitor resource usage

## Support Resources

- **Official Documentation**: https://www.odoo.com/documentation/18.0/
- **Community Forum**: https://www.odoo.com/forum
- **GitHub Issues**: Report bugs to official repository
- **Odoo Apps Store**: Browse additional modules

---

**Document Version**: 1.0
**Last Updated**: January 2024
**Odoo Version**: 18.0 Community Edition