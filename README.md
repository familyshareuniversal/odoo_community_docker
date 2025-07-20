# Odoo Community Edition - Docker Setup

This repository contains a complete Docker-based setup for Odoo Community Edition 18.0 with all official modules.

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)
```bash
# 1. Clone this repository
git clone [repository-url] odoo_community
cd odoo_community

# 2. Run automated setup (includes database + all modules)
./scripts/1_auto_setup_complete.sh

# 3. Wait ~45 minutes for complete setup
# Then access at http://localhost:8069
```

### Option 2: Manual Setup
```bash
# 1. Clone this repository
git clone [repository-url] odoo_community
cd odoo_community

# 2. Start Odoo
./scripts/start.sh

# 3. Open in browser
# http://localhost:8069
```

## 📋 What's Included

- **Odoo 18.0** Community Edition (Latest)
- **PostgreSQL 15** Database
- **All Official Modules** Pre-installed
- **Docker Compose** Configuration
- **Automated Setup** Script - One command installs everything!
- **Backup/Restore** Scripts
- **Comprehensive Documentation**

## 📁 Project Structure

```
odoo_community/
├── docker-compose.yml        # Docker services configuration
├── config/                  # Odoo configuration files
│   ├── odoo.conf           # Main configuration
│   ├── auto_odoo.conf      # Automated setup config
│   └── modules_list.txt    # All official modules list
├── scripts/                # Utility scripts
│   ├── start.sh           # Start services
│   ├── stop.sh            # Stop services
│   ├── backup.sh          # Backup data
│   ├── restore.sh         # Restore from backup
│   ├── 1_auto_setup_complete.sh  # ONE-CLICK SETUP!
│   ├── 2_create_demo_db.sh      # Create database
│   ├── 3_setup_admin_user.py    # Configure admin
│   ├── 4_install_all_modules.sh # Install modules
│   └── 0_check_status.sh        # Check installation
├── addons/                # Custom addons directory
├── data/                  # Persistent data
├── backups/               # Backup files
├── logs/                  # Log files
├── .env.example           # Environment template
├── .gitignore             # Git ignore rules
├── README.md              # This file
├── SETUP_GUIDE.md         # Detailed setup guide
├── QUICK_START.md         # Quick reference for team
└── AUTOMATED_SETUP.md     # Automated setup documentation

```

## 📚 Documentation

- **[AUTOMATED_SETUP.md](AUTOMATED_SETUP.md)** - Automated setup guide (recommended!)
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Complete manual setup guide
- **[QUICK_START.md](QUICK_START.md)** - Quick reference for daily use

## 🛠️ Key Features

- ✅ **One-Click Setup** - Run `1_auto_setup_complete.sh` and relax!
- ✅ **Zero Configuration** - Works out of the box
- ✅ **All Official Modules** - Automatically installs 150+ modules
- ✅ **Demo Data Included** - Sample data for immediate testing
- ✅ **Automated Backups** - Built-in backup/restore scripts
- ✅ **Production Ready** - Optimized settings included
- ✅ **macOS Optimized** - Tested on macOS (Intel & Apple Silicon)

## 🎯 Available Modules

### Core Business
- Sales & CRM
- Purchase & Inventory
- Manufacturing (MRP)
- Project Management
- Invoicing

### Human Resources
- Employees Directory
- Time Off Management
- Recruitment
- Attendance Tracking

### Website & Marketing
- Website Builder
- eCommerce
- Email Marketing
- Blogs & Forums

### And Many More!
See [SETUP_GUIDE.md](SETUP_GUIDE.md#module-list) for complete list.

## 🔧 Requirements

- Docker Desktop
- 8GB RAM (minimum)
- 20GB free disk space
- macOS, Linux, or Windows

## 📞 Support

- **Documentation**: See `SETUP_GUIDE.md`
- **Quick Help**: See `QUICK_START.md`
- **Issues**: Create an issue in this repository
- **Odoo Docs**: https://www.odoo.com/documentation/18.0/

## 🔐 Security Notes

1. Change default passwords in:
   - `config/odoo.conf` (admin_passwd)
   - `.env` file (database passwords)
2. Use HTTPS in production
3. Regular backups are recommended

## 🚦 Quick Commands

```bash
# Automated complete setup (recommended for new developers)
./scripts/1_auto_setup_complete.sh

# Check installation status
./scripts/0_check_status.sh

# Start Odoo
./scripts/start.sh

# Stop Odoo
./scripts/stop.sh

# Backup data
./scripts/backup.sh

# Restore from backup
./scripts/restore.sh TIMESTAMP

# View logs
docker-compose logs -f
```

### 🎯 Default Login Credentials (after automated setup)
- **URL**: http://localhost:8069
- **Email**: rohitsoni@gmail.com
- **Password**: Rohit819
- **Database**: Demo

---

**Version**: Odoo 18.0 Community Edition  
**Last Updated**: January 2024