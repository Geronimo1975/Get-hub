# Frontend Not Working - Solution Guide

## Problem

The frontend interface appears empty or broken because **the database has no content**. The Django application is running correctly, but needs data to display.

## Current Status

✅ **Working**:
- Django application is running
- Database is connected
- Static files (CSS/JS) are loading
- HTML templates are rendering
- Admin dashboard is accessible

❌ **Missing**:
- Homepage slider content
- About section content
- Services data
- Projects/portfolio items
- Blog posts
- Website settings (logo, contact info, etc.)

## Why This Happens

TCG Agency is a **Content Management System**. A fresh installation has:
- ✅ Database structure (tables created by migrations)
- ❌ No actual content in those tables

The original `Install/data.sql` file contains sample data, but:
- It's in MySQL format (we're using PostgreSQL)
- It hasn't been imported yet

## Solution Options

### Option 1: Add Content Through Admin Dashboard (Recommended)

This is the proper way to use the CMS:

1. **Login to Admin Dashboard**
   ```
   URL: http://80.134.74.61:8001/dashboard/
   Username: admin
   Password: admin123
   ```

2. **Add Website Settings**
   - Go to Dashboard → Settings → Website Settings
   - Add: Site name, logo, contact info, social links

3. **Add Homepage Content**
   - Go to Dashboard → Pages → Home
   - Add slider images
   - Add about section content
   - Add featured services

4. **Add Services**
   - Go to Dashboard → Services → Add Service
   - Create your service listings

5. **Add Projects**
   - Go to Dashboard → Projects → Add Project
   - Showcase your portfolio

6. **Add Blog Posts**
   - Go to Dashboard → Blog → Create Post
   - Write blog content

### Option 2: Convert and Import Sample Data

If you want the demo/sample data from `Install/data.sql`:

**Steps to import sample data:**

```bash
# 1. The data.sql is in MySQL format, we need to convert it
# This requires manual conversion or a conversion tool

# 2. For now, the easiest way is to use Django fixtures
# We can create a fixture from the Install database

# Option A: Use Django's dumpdata/loaddata
# (Requires setting up MySQL temporarily)

# Option B: Manually recreate key content through admin
# (Recommended for production)
```

### Option 3: Quick Start - Add Minimal Settings

Let me create a script to add basic settings:

```python
# Run this in Django shell
python manage.py shell

# Then execute:
from apps.settings.models import websiteSetting, SeoSetting, headerFooterSetting

# Create website settings
if not websiteSetting.objects.exists():
    websiteSetting.objects.create(
        application_name="Get-hub Agency",
        tagline="Your Creative Partner",
        email="info@gethub.com",
        phone="+1234567890",
        address="123 Business St, City, Country",
        description="A modern creative agency platform"
    )

# Create SEO settings
if not SeoSetting.objects.exists():
    SeoSetting.objects.create(
        meta_title="Get-hub Agency - Creative Solutions",
        meta_description="Professional creative agency services",
        meta_keywords="agency, creative, design, development"
    )

# Create header/footer settings
if not headerFooterSetting.objects.exists():
    headerFooterSetting.objects.create(
        footer_text="© 2025 Get-hub Agency. All rights reserved."
    )

print("Basic settings created!")
```

## Step-by-Step: Populate Your Site

### 1. Website Settings (Required)

```bash
# SSH to server
ssh n8n

# Access Django shell
cd ~/Get-hub
docker-compose exec web python manage.py shell
```

Then run the script from Option 3 above.

### 2. Add Homepage Slider

Login to dashboard and:
1. Navigate to **Pages → Home → Slider Section**
2. Click **Add New Slider**
3. Add:
   - Title
   - Subtitle
   - Description
   - Upload image
   - Add button text and link

### 3. Add Services

1. Navigate to **Services → Add Service**
2. Fill in:
   - Service name
   - Description
   - Icon/image
   - Category

### 4. Add Projects

1. Navigate to **Projects → Add Project**
2. Fill in:
   - Project name
   - Description
   - Category
   - Images
   - Client info

### 5. Add Blog Posts

1. Navigate to **Blog → Create Post**
2. Fill in:
   - Title
   - Content (using CKEditor)
   - Category
   - Featured image

## Verification

After adding content, check these URLs:

1. **Homepage**: http://80.134.74.61:8001/
   - Should show slider
   - Services section
   - Projects section

2. **Services**: http://80.134.74.61:8001/services/
   - Lists all services

3. **Projects**: http://80.134.74.61:8001/projects/
   - Portfolio gallery

4. **Blog**: http://80.134.74.61:8001/blog/
   - Blog post listing

5. **About**: http://80.134.74.61:8001/about/
   - About page content

## Quick Fix Script

Create this file on your server to add basic content:

```bash
# Create file: ~/Get-hub/populate_basic_data.py
```

```python
#!/usr/bin/env python
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from apps.settings.models import websiteSetting, SeoSetting, headerFooterSetting

print("Creating basic website settings...")

# Website settings
ws, created = websiteSetting.objects.get_or_create(
    defaults={
        'application_name': 'Get-hub Agency',
        'tagline': 'Your Creative Partner',
        'email': 'info@gethub.com',
        'phone': '+1234567890',
        'address': '123 Business Street, City, Country',
        'description': 'Welcome to Get-hub Agency'
    }
)
print(f"✓ Website Settings: {'Created' if created else 'Already exists'}")

# SEO settings
seo, created = SeoSetting.objects.get_or_create(
    defaults={
        'meta_title': 'Get-hub Agency',
        'meta_description': 'Creative agency platform',
        'meta_keywords': 'agency, creative, django'
    }
)
print(f"✓ SEO Settings: {'Created' if created else 'Already exists'}")

# Header/Footer
hf, created = headerFooterSetting.objects.get_or_create(
    defaults={
        'footer_text': '© 2025 Get-hub Agency. All rights reserved.'
    }
)
print(f"✓ Header/Footer: {'Created' if created else 'Already exists'}")

print("\n✅ Basic settings created successfully!")
print("\nNext steps:")
print("1. Login to dashboard: http://80.134.74.61:8001/dashboard/")
print("2. Add homepage slider content")
print("3. Add services, projects, and blog posts")
```

**Run it:**
```bash
ssh n8n
cd ~/Get-hub
docker-compose exec web python populate_basic_data.py
```

## Common Issues

### Issue 1: Page Appears Blank
**Cause**: No content in database
**Solution**: Add content through admin dashboard

### Issue 2: CSS Not Loading
**Cause**: Static files not collected
**Solution**:
```bash
docker-compose exec web python manage.py collectstatic --noinput
docker-compose restart web
```

### Issue 3: Images Not Showing
**Cause**: No images uploaded
**Solution**: Upload images through admin dashboard

### Issue 4: "Application Name" Showing
**Cause**: Website settings not configured
**Solution**: Add website settings through dashboard

## Testing the Frontend

1. **Check if static files work**:
   ```bash
   curl -I http://80.134.74.61:8001/static/front/assets/css/bootstrap.min.css
   # Should return: HTTP/1.1 200 OK
   ```

2. **Check if homepage renders**:
   ```bash
   curl http://80.134.74.61:8001/ | grep -i "html"
   # Should return HTML content
   ```

3. **Check if admin works**:
   ```bash
   curl -I http://80.134.74.61:8001/dashboard/
   # Should return: HTTP/1.1 302 Found (redirect to login)
   ```

## Summary

The frontend is **technically working** but appears broken because:
- ✅ Application is running
- ✅ Templates are rendering
- ✅ Static files are loading
- ❌ Database is empty (no content to display)

**Action Required**: Add content through the admin dashboard at http://80.134.74.61:8001/dashboard/

**Quick Start**:
1. Login to dashboard
2. Go to Settings → Configure website info
3. Go to Pages → Home → Add slider content
4. Add services, projects, blog posts as needed

The frontend will work properly once you add content!
