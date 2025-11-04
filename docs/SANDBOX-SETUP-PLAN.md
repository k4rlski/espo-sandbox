# Sandbox Environment Setup Plan
## sandbox.permtrak.com - Safe Testing Ground for Field/Layout Management

**Date:** November 3, 2025  
**Purpose:** Create disposable testing environment for Entity Manager experiments  
**Strategy:** Preserve dev.permtrak.com, use sandbox for aggressive testing

---

## 🎯 OBJECTIVES

### **Primary Goal:**
Create sandbox.permtrak.com as a safe testing environment for:
- ✅ Testing Layout Manager with cache disabled
- ✅ Field deletion experiments
- ✅ Removing unused fields from layouts
- ✅ Validating Entity Manager workflows
- ✅ Avoiding entity split (preserve front-end data display systems)

### **Keep Safe:**
- ✅ **dev.permtrak.com** - Working baseline (Phase 6 complete, 82.3% capacity)
- ✅ **prod.permtrak.com** - Production system (unchanged)

### **Experiment On:**
- 🧪 **sandbox.permtrak.com** - Disposable testing ground

---

## 📋 SETUP PLAN

### **Phase 1: Copy dev.permtrak.com → sandbox.permtrak.com**

This replicates the exact process used to copy prod → dev:

```bash
# 1. SSH into permtrak.com server
ssh permtrak2@permtrak.com

# 2. Create backup/archive of current sandbox (if exists)
cd /home/permtrak2/
if [ -d "sandbox.permtrak.com" ]; then
    tar -czf sandbox.permtrak.com-backup-$(date +%Y%m%d_%H%M%S).tar.gz sandbox.permtrak.com
    mv sandbox.permtrak.com-backup-*.tar.gz ~/backups/ 2>/dev/null || true
fi

# 3. Copy dev.permtrak.com to sandbox.permtrak.com
rsync -av --progress \
    --exclude 'data/cache/*' \
    --exclude 'data/logs/*' \
    --exclude 'data/upload/*' \
    dev.permtrak.com/ sandbox.permtrak.com/

# 4. Set correct permissions
cd sandbox.permtrak.com
chown -R www-data:www-data .
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
chmod +x bin/command

# 5. Update data/config.php for sandbox
cd /home/permtrak2/sandbox.permtrak.com/EspoCRM
```

### **Phase 2: Configure sandbox.permtrak.com**

Edit `data/config.php`:

```php
<?php
return [
    'database' => [
        'host' => 'permtrak.com',
        'port' => '',
        'charset' => NULL,
        'driver' => 'pdo_mysql',
        'dbname' => 'permtrak2_sandbox',  // ← NEW DATABASE
        'user' => 'permtrak2_sandbox',    // ← NEW USER (or reuse dev)
        'password' => 'PASSWORD_HERE',    // ← Database password
    ],
    'siteUrl' => 'https://sandbox.permtrak.com/EspoCRM',  // ← NEW URL
    'useCache' => false,  // ← CRITICAL: Cache disabled for testing!
    'defaultPermissions' => [
        'user' => 'www-data',
        'group' => 'www-data',
    ],
    // ... rest of config from dev
];
```

### **Phase 3: Database Setup**

```bash
# Option A: Copy dev database to new sandbox database
mysqldump -h permtrak.com -u permtrak2_dev -p'PASSWORD' permtrak2_dev > /tmp/dev_backup.sql

# Create new database for sandbox
mysql -h permtrak.com -u root -p <<EOF
CREATE DATABASE IF NOT EXISTS permtrak2_sandbox CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'permtrak2_sandbox'@'%' IDENTIFIED BY 'SANDBOX_PASSWORD';
GRANT ALL PRIVILEGES ON permtrak2_sandbox.* TO 'permtrak2_sandbox'@'%';
FLUSH PRIVILEGES;
EOF

# Import dev data to sandbox
mysql -h permtrak.com -u permtrak2_sandbox -p'SANDBOX_PASSWORD' permtrak2_sandbox < /tmp/dev_backup.sql

# OR Option B: Reuse dev database (if you want live sync)
# Just use permtrak2_dev database in config.php (not recommended for destructive testing)
```

### **Phase 4: Update .htaccess and Web Server Config**

```bash
# Update .htaccess if needed (RewriteBase, etc.)
cd /home/permtrak2/sandbox.permtrak.com/EspoCRM
nano .htaccess

# Check RewriteBase
# RewriteBase /EspoCRM/

# Ensure Apache/Nginx has config for sandbox.permtrak.com
# (Check with your hosting setup - subdomain might already be configured)
```

### **Phase 5: SSL Certificate**

```bash
# Check if sandbox.permtrak.com already has SSL
curl -I https://sandbox.permtrak.com

# If not, create SSL certificate (if using Let's Encrypt):
certbot --apache -d sandbox.permtrak.com
# OR
certbot --nginx -d sandbox.permtrak.com

# Verify SSL works
curl -I https://sandbox.permtrak.com/EspoCRM
```

### **Phase 6: Clear Cache and Rebuild**

```bash
cd /home/permtrak2/sandbox.permtrak.com/EspoCRM

# Clear cache
rm -rf data/cache/*
php clear_cache.php

# Rebuild (to ensure database schema matches)
php rebuild.php

# Verify cache is disabled
grep useCache data/config.php
# Should show: 'useCache' => false,
```

### **Phase 7: Pull GitHub Repo**

```bash
# Pull latest optimizations from GitHub
cd /home/permtrak2/sandbox.permtrak.com/EspoCRM

# Pull entityDefs from GitHub repo
# (Assuming you want the Phase 6 optimized metadata)
cd custom/Espo/Custom/Resources/metadata/entityDefs/

# Backup current files
mkdir -p ~/backups/sandbox-entitydefs-$(date +%Y%m%d_%H%M%S)
cp *.json ~/backups/sandbox-entitydefs-*/

# Pull from GitHub (you'll need to clone/pull the repo)
# Or manually copy from your local repo:
```

From local machine:
```bash
# Copy optimized TESTPERM.json to sandbox
scp "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-dev/entityDefs/TESTPERM.json" \
    permtrak2@permtrak.com:/home/permtrak2/sandbox.permtrak.com/EspoCRM/custom/Espo/Custom/Resources/metadata/entityDefs/TESTPERM.json

# Copy optimized PWD.json to sandbox
scp "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-dev/entityDefs/PWD.json" \
    permtrak2@permtrak.com:/home/permtrak2/sandbox.permtrak.com/EspoCRM/custom/Espo/Custom/Resources/metadata/entityDefs/PWD.json
```

Then on server:
```bash
# Set permissions
cd /home/permtrak2/sandbox.permtrak.com/EspoCRM
chown -R www-data:www-data custom/
php clear_cache.php
```

### **Phase 8: Initial Testing**

```bash
# Test that sandbox loads
curl -I https://sandbox.permtrak.com/EspoCRM

# Test admin login
# Browse to: https://sandbox.permtrak.com/EspoCRM
# Login with admin credentials

# Verify cache is disabled:
# Administration → Settings → System
# "Use Cache" should be unchecked ☐

# Verify TESTPERM optimization:
# Check that TESTPERM records open/save correctly
# Check row size is ~6,685 bytes (82.3% capacity)
```

---

## 🧪 TESTING PLAN (After Setup)

### **Experiment 1: Remove Unused Fields from TESTPERM Layout**

**Goal:** Clean up the 28 unused fields sitting in right panel dock

**Steps:**
1. ✅ Cache already disabled (verified in config.php)
2. Go to: Layout Manager → TESTPERM → Detail
3. Remove `trx` field from layout (confirmed deleted in Phase 4)
4. Remove other verified unused fields
5. Save and test
6. Verify records still open/save correctly

**Expected Result:**
- Cleaner layout
- Faster page loads
- No errors

---

### **Experiment 2: Delete Truly Unused Fields from Entity**

**Goal:** Test Entity Manager field deletion with cache disabled

**Fields to Test (100% NULL confirmed):**
- `parentid` (already TEXT, 100% NULL)
- Others after verification

**Steps:**
1. Verify cache disabled
2. Check field has no data:
   ```sql
   SELECT COUNT(*) FROM t_e_s_t_p_e_r_m WHERE fieldname IS NOT NULL AND fieldname != '';
   ```
3. If count = 0, safe to delete
4. Use Entity Manager → TESTPERM → Fields → Delete
5. Clear cache (even though disabled, good practice)
6. Test TESTPERM records open/save
7. Check for any errors

**Expected Result:**
- Field deleted successfully
- No Error 500
- Records still work

---

### **Experiment 3: PWD Field Positioning**

**Goal:** Arrange PWD fields in desired positions

**Steps:**
1. Verify cache disabled
2. Go to: Layout Manager → PWD → Detail
3. Drag fields to desired positions
4. Save
5. Test PWD records show fields in correct positions
6. Verify no layout corruption

**Expected Result:**
- Fields positioned correctly
- Layout saves and persists
- No errors

---

### **Experiment 4: Aggressive Field Cleanup**

**Goal:** Remove all truly unused fields to maximize row size reduction

**Approach:**
1. Run usage analysis on all VARCHAR fields
2. Convert large VARCHARs to TEXT (if not needed for indexing)
3. Delete fields with 0% usage
4. Monitor for any issues

**Expected Result:**
- Further row size reduction
- Cleaner entity definitions
- Stable system

---

## 📊 SUCCESS METRICS

### **Sandbox is Successful If:**
- ✅ Layout Manager works without errors (cache disabled)
- ✅ Field deletions work without Error 500
- ✅ Fields can be removed from layouts safely
- ✅ PWD fields can be repositioned
- ✅ TESTPERM maintains 82.3% capacity or better
- ✅ No entity split needed!

### **Apply to Dev If:**
All sandbox experiments succeed for 1-2 days without issues

### **Apply to Prod If:**
Dev works perfectly for 1 week after applying sandbox changes

---

## 🔒 SAFETY MEASURES

### **Backups Before Each Experiment:**
```bash
# Backup database
mysqldump -h permtrak.com -u permtrak2_sandbox -p permtrak2_sandbox > \
    ~/backups/sandbox-$(date +%Y%m%d_%H%M%S).sql

# Backup entityDefs
tar -czf ~/backups/sandbox-metadata-$(date +%Y%m%d_%H%M%S).tar.gz \
    /home/permtrak2/sandbox.permtrak.com/EspoCRM/custom/Espo/Custom/Resources/metadata/
```

### **Rollback Plan:**
If something breaks:
1. Restore database from backup
2. Restore metadata from backup
3. Clear cache
4. Rebuild
5. Or: Nuke sandbox and re-copy from dev

### **Preserved Environments:**
- ✅ **prod.permtrak.com** - Never touched
- ✅ **dev.permtrak.com** - Phase 6 complete, working baseline
- 🧪 **sandbox.permtrak.com** - Disposable testing ground

---

## 📝 DOCUMENTATION TO CREATE

### **During Setup:**
- [ ] Document exact database credentials used
- [ ] Document SSL certificate status
- [ ] Document web server config (if needed)
- [ ] Screenshot sandbox working with cache disabled

### **During Testing:**
- [ ] Document each experiment's results
- [ ] Screenshot successful field deletions
- [ ] Screenshot successful layout changes
- [ ] Document any errors encountered

### **After Success:**
- [ ] Create migration plan for dev.permtrak.com
- [ ] Create migration plan for prod.permtrak.com
- [ ] Update best practices guide

---

## 🎯 GOALS SUMMARY

### **Primary Objective:**
**Prove that cache disabled + Entity Manager = Reliable field management**

### **Secondary Objectives:**
- ✅ Clean up TESTPERM layout (remove 28 unused fields from dock)
- ✅ Position PWD fields correctly
- ✅ Delete truly unused fields safely
- ✅ Further optimize row sizes
- ✅ **AVOID entity split** (preserve front-end systems)

### **Success Criteria:**
If we can reliably:
1. Remove fields from layouts
2. Delete unused fields from entities
3. Position fields in layouts
4. All without errors or cache issues

Then we've solved the Entity Manager problem and can apply to dev/prod!

---

## 💡 KEY INSIGHTS

### **Why Sandbox Strategy is Smart:**
- ✅ Preserves working dev.permtrak.com
- ✅ Allows aggressive testing
- ✅ Easy to nuke and restart
- ✅ No risk to production data
- ✅ Can test "nuclear options" safely

### **Why Cache Disabled is Critical:**
- ✅ Eliminates stale metadata issues
- ✅ Changes take effect immediately
- ✅ Entity Manager works as designed
- ✅ No unexpected behavior

### **Why Entity Split is Undesirable:**
- ⚠️ Breaks front-end data display systems
- ⚠️ Complex migration
- ⚠️ Requires extensive testing
- ⚠️ May not be necessary if field cleanup works

---

## 🚀 NEXT SESSION PLAN

### **When You Return:**
1. Review this document
2. Execute setup steps (Phase 1-8)
3. Verify sandbox.permtrak.com works
4. Start with Experiment 1 (remove trx from layout)
5. Document results
6. Continue with other experiments

### **Expected Timeline:**
- Setup: 30-60 minutes
- Experiment 1: 15 minutes
- Experiment 2: 30 minutes per field
- Experiment 3: 15 minutes
- Experiment 4: Ongoing

---

## 📋 QUICK REFERENCE

### **Environments:**
- **prod.permtrak.com** - Production (unchanged)
- **dev.permtrak.com** - Working baseline (Phase 6, 82.3%)
- **sandbox.permtrak.com** - Testing ground (cache disabled)

### **Database Credentials:**
- dev: `permtrak2_dev` / password from dev config
- sandbox: `permtrak2_sandbox` / (to be set)

### **Cache Status:**
- prod: Enabled (normal)
- dev: Enabled (normal)
- sandbox: **DISABLED** (for testing)

### **GitHub Branch:**
- Baseline: `testperm-working-baseline-error500-fixed`
- Latest: `testperm-phase6-complete-under-limit`
- Main: Always up-to-date

---

## STATUS

**Plan:** ✅ Complete  
**Setup:** ⏳ Pending (next session)  
**Testing:** ⏳ Pending (after setup)  
**Results:** ⏳ TBD  

**Ready to execute when you return!** 🚀

