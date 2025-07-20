# Odoo Community Edition - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Prerequisites
- Docker Desktop is installed and running
- You have the project files

### Step 1: Start Odoo
```bash
cd /path/to/odoo_community
./scripts/start.sh
```

### Step 2: Access Odoo
Open your browser and go to: **http://localhost:8069**

### Step 3: Login
- **Database**: Select your database (Demo for automated setup)
- **Username**: admin
- **Password**: admin

## 📱 Common Tasks

### Installing a New Module
1. Click **Apps** menu (grid icon)
2. Remove "Apps" filter to see all modules
3. Search for the module name
4. Click **Install**

### Creating a Customer
1. Go to **Sales** or **CRM** app
2. Click **Customers** → **Create**
3. Fill in customer details
4. Click **Save**

### Creating a Sales Order
1. Go to **Sales** app
2. Click **Orders** → **Quotations** → **Create**
3. Select customer
4. Add products
5. Click **Confirm**

### Creating a Product
1. Go to **Inventory** or **Sales** app
2. Click **Products** → **Products** → **Create**
3. Fill in product details
4. Set price
5. Click **Save**

## 🛠️ Daily Operations

### Starting Your Day
```bash
# Start Odoo if not running
./scripts/start.sh

# Check status
docker-compose ps
```

### Ending Your Day
```bash
# Optional: Create a backup
./scripts/backup.sh

# Stop services (optional)
./scripts/stop.sh
```

## 📊 Useful Shortcuts

### Keyboard Shortcuts
- **Alt + S**: Save
- **Alt + A**: Create new record
- **Alt + D**: Discard changes
- **Ctrl + K**: Quick search
- **Esc**: Close dialog/Cancel

### Quick Navigation
- Click company logo → Main apps menu
- Use breadcrumbs to navigate back
- Star ⭐ frequently used menus

## 🔧 Troubleshooting

### Can't Access Odoo
```bash
# Check if services are running
docker-compose ps

# Restart services
./scripts/stop.sh
./scripts/start.sh
```

### Forgot Password
1. Contact your Odoo administrator
2. They can reset from **Settings** → **Users**

### Module Not Working
1. Check if all dependencies are installed
2. Try updating the module list:
   - **Apps** → **Update Apps List**
3. Restart Odoo services

## 📚 Getting Help

### In-App Help
- Click **?** icon in top menu
- Hover over fields for tooltips
- Check module descriptions in Apps

### Documentation
- Full guide: See `SETUP_GUIDE.md`
- Official docs: https://www.odoo.com/documentation/18.0/

### Support Contacts
- Technical Admin: [Your IT contact]
- Odoo Champion: [Internal expert]
- Emergency: [Contact info]

## 🎯 Module Quick Reference

### Most Used Modules
| Module | Purpose | Menu Location |
|--------|---------|---------------|
| **Sales** | Quotes & Orders | Main Menu |
| **CRM** | Leads & Opportunities | Main Menu |
| **Inventory** | Stock Management | Main Menu |
| **Purchase** | Vendor Orders | Main Menu |
| **Employees** | HR Directory | Main Menu |
| **Project** | Task Management | Main Menu |
| **Invoicing** | Customer Invoices | Main Menu |
| **Website** | Company Website | Main Menu |

### Quick Actions by Role

#### Sales Person
1. **CRM** → Track leads
2. **Sales** → Create quotations
3. **Contacts** → Manage customers

#### Inventory Manager
1. **Inventory** → Check stock
2. **Purchase** → Order products
3. **Reports** → Stock valuation

#### HR Manager
1. **Employees** → Employee records
2. **Time Off** → Approve leaves
3. **Recruitment** → Job postings

#### Project Manager
1. **Project** → Manage tasks
2. **Timesheet** → Track time
3. **Reports** → Project status

## 💡 Pro Tips

1. **Use Filters**: Save frequently used filters
2. **Favorites**: Star important records
3. **Chatter**: Use @ mentions in messages
4. **Activities**: Schedule follow-ups
5. **Dashboard**: Customize your home dashboard

---

**Remember**: Odoo saves automatically as you work. No need to constantly save!

**Need more help?** Check the full `SETUP_GUIDE.md` or ask your Odoo administrator.