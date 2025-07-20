#!/usr/bin/env python3
"""
Setup admin user with specific email and password
Since Odoo CLI creates admin with default 'admin' login,
we need to update it via XML-RPC after database creation
"""

import xmlrpc.client
import sys
import time

# Configuration
ODOO_URL = "http://localhost:8069"
DB_NAME = "Demo"
MASTER_PASSWORD = "Rohit819"
ADMIN_EMAIL = "rohitsoni@gmail.com"
ADMIN_PASSWORD = "Rohit819"
DEFAULT_ADMIN_PASSWORD = "Rohit819"  # The master password is used as default admin password

def setup_admin_user():
    """Update admin user with correct email and password"""
    
    print(f"Connecting to Odoo at {ODOO_URL}...")
    
    try:
        # Connect to Odoo
        common = xmlrpc.client.ServerProxy(f'{ODOO_URL}/xmlrpc/2/common')
        
        # Authenticate with default admin credentials
        print("Authenticating with default admin credentials...")
        uid = common.authenticate(DB_NAME, 'admin', DEFAULT_ADMIN_PASSWORD, {})
        
        if not uid:
            print("❌ Failed to authenticate with default admin credentials!")
            print("Trying with the target email...")
            # Try with the target email in case it was already changed
            uid = common.authenticate(DB_NAME, ADMIN_EMAIL, ADMIN_PASSWORD, {})
            if not uid:
                print("❌ Failed to authenticate!")
                return False
            else:
                print("✅ Admin user already configured correctly!")
                return True
        
        print(f"✅ Authenticated successfully (UID: {uid})")
        
        # Connect to object service
        models = xmlrpc.client.ServerProxy(f'{ODOO_URL}/xmlrpc/2/object')
        
        # Update admin user
        print(f"Updating admin user email to: {ADMIN_EMAIL}")
        
        # Search for admin user (ID is usually 2, but let's search to be sure)
        admin_ids = models.execute_kw(
            DB_NAME, uid, DEFAULT_ADMIN_PASSWORD,
            'res.users', 'search',
            [[['id', '=', 2]]]
        )
        
        if not admin_ids:
            print("❌ Admin user not found!")
            return False
        
        admin_id = admin_ids[0]
        print(f"Found admin user with ID: {admin_id}")
        
        # Update admin user
        result = models.execute_kw(
            DB_NAME, uid, DEFAULT_ADMIN_PASSWORD,
            'res.users', 'write',
            [[admin_id], {
                'login': ADMIN_EMAIL,
                'email': ADMIN_EMAIL,
                'password': ADMIN_PASSWORD
            }]
        )
        
        if result:
            print("✅ Admin user updated successfully!")
            
            # Verify the update
            print("Verifying update...")
            time.sleep(2)  # Give Odoo a moment to process
            
            # Try to authenticate with new credentials
            new_uid = common.authenticate(DB_NAME, ADMIN_EMAIL, ADMIN_PASSWORD, {})
            if new_uid:
                print("✅ Successfully authenticated with new credentials!")
                print(f"   - Login: {ADMIN_EMAIL}")
                print(f"   - Password: {ADMIN_PASSWORD}")
                return True
            else:
                print("⚠️  Warning: Update seemed successful but authentication failed")
                return False
        else:
            print("❌ Failed to update admin user!")
            return False
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return False

def main():
    """Main function"""
    print("=" * 50)
    print("Admin User Setup Script")
    print("=" * 50)
    
    # Wait a bit to ensure database is fully initialized
    print("Waiting for database to be fully initialized...")
    print("This may take up to 60 seconds after database creation...")
    
    # Try multiple times with increasing delays
    max_attempts = 6
    for attempt in range(max_attempts):
        try:
            print(f"Attempt {attempt + 1}/{max_attempts} - Checking if Odoo is ready...")
            # Test connection
            test_common = xmlrpc.client.ServerProxy(f'{ODOO_URL}/xmlrpc/2/common')
            version = test_common.version()
            if version:
                print("✅ Odoo is ready!")
                break
        except Exception as e:
            if attempt < max_attempts - 1:
                wait_time = 10 * (attempt + 1)
                print(f"Odoo not ready yet, waiting {wait_time} seconds...")
                time.sleep(wait_time)
            else:
                print(f"❌ Odoo failed to become ready after {max_attempts} attempts")
                sys.exit(1)
    
    if setup_admin_user():
        print("\n✅ Admin user setup completed successfully!")
        sys.exit(0)
    else:
        print("\n❌ Admin user setup failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()