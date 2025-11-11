# DevOps Plan: EspoCRM + WP Reports + Stripe Transaction Mapping

**Created:** 2025-11-10  
**Environment:** Sandbox (sandbox.permtrak.com/EspoCRM + rpx-sb.permtrak.com)  
**Status:** Planning Phase  

---

## 🎯 Mission Overview

Build out domain management entity in EspoCRM Sandbox, enhance WordPress domain management report, test with fresh production data, and validate Stripe transaction mapper integration.

**Key Principle:** Work in Sandbox until proficient, then migrate to Dev → Staging → Prod workflow.

---

## 📋 Phase Line Alpha: Domain Management Build-Out

**Goal:** Edit EspoCRM entity, rebuild safely, edit WP report, import fresh prod data

### Step 1: Edit EspoCRM Entity **[espocrm]**

**A. Add ENUM Value to `statdomain` Field**
1. Open **Private Browser Tab**
2. Navigate to: `https://sandbox.permtrak.com/EspoCRM/#Admin/entityManager`
3. Edit `statdomain` ENUM field
4. Add new value: **"Transfer"**
5. Save changes

**B. Post-Edit Validation Sequence** **[espocrm]**
```bash
# Clear cache (even though sandbox cache is OFF)
ssh permtrak2@permtrak.com "cd /home/permtrak2/sandbox.permtrak.com/EspoCRM && php command.php clear-cache"

# Rebuild
ssh permtrak2@permtrak.com "cd /home/permtrak2/sandbox.permtrak.com/EspoCRM && php command.php rebuild"

# Rebuild --hard
ssh permtrak2@permtrak.com "cd /home/permtrak2/sandbox.permtrak.com/EspoCRM && php command.php rebuild --hard"
```

**C. Verify Changes**
- Check ENUM value appears in UI
- Test record save/load
- Confirm no errors in EspoCRM logs

---

### Step 2: Add New Field `domxfercode` **[espocrm]**

**A. Create Field via Entity Manager**
1. Open **Private Browser Tab**
2. Navigate to: `https://sandbox.permtrak.com/EspoCRM/#Admin/entityManager`
3. Add new field:
   - **Name:** `domxfercode`
   - **Label:** Domain Transfer Code
   - **Type:** VARCHAR (suggest length: 50)
   - **Entity:** (specify which entity - PWD? TESTPERM? New Domain entity?)
4. Add to layout
5. Save changes

**B. Post-Edit Validation Sequence** **[espocrm]**
```bash
# Same sequence as Step 1B
clear-cache → rebuild → rebuild --hard
```

**C. Verify Changes**
- Check field appears in layout
- Test data entry
- Confirm database column created correctly

---

### Step 3: Edit WordPress Domain Management Report **[wordpress-reports]**

**A. Download Current Widget**
```bash
# Local path
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/3-REPORTS/WORDPRESS-AUTOMATION/reports-sb/widgets"

# Download from server
scp permtrak2@permtrak.com:/home/permtrak2/rpx-sb.permtrak.com/wp-content/themes/genesis/lib/widgets/domain-management-report.php ./
```

**B. Edit Widget** **[wordpress-reports]**
- Improve styling (CSS/HTML)
- Add new column for `domxfercode` field
- Update SQL query to join with EspoCRM table
- Enhance UI/UX

**C. Test Locally**
- Syntax check PHP
- Verify SQL query structure
- Test in private browser tab

**D. Deploy to Server** **[wordpress-reports]**
```bash
scp "./domain-management-report.php" \
    permtrak2@permtrak.com:/home/permtrak2/rpx-sb.permtrak.com/wp-content/themes/genesis/lib/widgets/
```

**E. Commit to GitHub** **[wordpress-reports]**
```bash
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/3-REPORTS/WORDPRESS-AUTOMATION/reports-sb"
git add widgets/domain-management-report.php
git commit -m "[wordpress-reports] Enhanced domain management report styling and added domxfercode field"
git push origin main
```

---

### Step 4: Import Fresh Production Data **[mysql data sync]**

**Goal:** Get current production data into sandbox to test changes with real data

#### Option A: Import Specific Table Only **[mysql data sync]**

**Best for:** Testing domain-specific changes without affecting other data

```bash
# Export specific table from prod
ssh permtrak2@permtrak.com "mysqldump -u permtrak2_prod \
    -p'xX-6x8-Wcx6y8-9hjJFe44VhA-Xx' \
    --single-transaction \
    permtrak2_prod <TABLE_NAME> > /tmp/prod_table_export.sql"

# Import to sandbox
ssh permtrak2@permtrak.com "mysql -u permtrak2_sandbox \
    -p'XTz5*]xF-Zx4=Lx-u' \
    permtrak2_sandbox < /tmp/prod_table_export.sql"

# Cleanup
ssh permtrak2@permtrak.com "rm /tmp/prod_table_export.sql"
```

**Notes:**
- Preserves existing sandbox data in other tables
- Won't affect c_stripetrx table (keeps your test mappings)
- Fast and surgical

#### Option B: Import Entire Database **[mysql data sync]**

**Best for:** Complete refresh with all current production data

```bash
# Export entire prod database
ssh permtrak2@permtrak.com "mysqldump -u permtrak2_prod \
    -p'xX-6x8-Wcx6y8-9hjJFe44VhA-Xx' \
    --single-transaction \
    permtrak2_prod > /tmp/prod_full_export.sql"

# Drop & recreate sandbox database
ssh permtrak2@permtrak.com "mysql -u permtrak2_sandbox \
    -p'XTz5*]xF-Zx4=Lx-u' \
    -e 'DROP DATABASE IF EXISTS permtrak2_sandbox; CREATE DATABASE permtrak2_sandbox CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'"

# Import prod data
ssh permtrak2@permtrak.com "mysql -u permtrak2_sandbox \
    -p'XTz5*]xF-Zx4=Lx-u' \
    permtrak2_sandbox < /tmp/prod_full_export.sql"

# Rebuild to align schema with optimized metadata [espocrm]
ssh permtrak2@permtrak.com "cd /home/permtrak2/sandbox.permtrak.com/EspoCRM && php command.php rebuild --hard"

# Cleanup
ssh permtrak2@permtrak.com "rm /tmp/prod_full_export.sql"
```

**Notes:**
- ⚠️ **OVERWRITES** all sandbox data (including c_stripetrx)
- Need to re-run Stripe transaction mapper afterward
- Gets all latest production data
- `rebuild --hard` drops deleted fields (dateinvoicedlocal, swasmartlink)

#### Data Disparity Handling **[espocrm] [mysql data sync]**

**Known Issues:**
1. **Deleted Fields in Sandbox:**
   - `TESTPERM.dateinvoicedlocal` - Data will be dropped (acceptable)
   - `TESTPERM.swasmartlink` - Data will be dropped (acceptable)

2. **New Fields Added in Sandbox:**
   - `domxfercode` - Will be NULL for all imported records (expected)
   - `statdomain` ENUM "Transfer" value - Existing records won't use it yet (expected)

3. **TEXT Conversions:**
   - VARCHAR → TEXT conversions handled automatically
   - No data loss expected

**Validation After Import:**
```bash
# Check row sizes [espocrm]
ssh permtrak2@permtrak.com "mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox -e \"
SELECT 
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb,
    ROUND((data_length / (SELECT @@innodb_page_size)) / 
          (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='permtrak2_sandbox' AND table_name='t_e_s_t_p_e_r_m') * 100, 2) AS row_pct
FROM information_schema.tables
WHERE table_schema = 'permtrak2_sandbox' 
AND table_name IN ('t_e_s_t_p_e_r_m', 'p_w_d', 'c_stripetrx')
ORDER BY table_name;
\""

# Verify new field exists [espocrm]
ssh permtrak2@permtrak.com "mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox -e \"
SHOW COLUMNS FROM <TABLE_NAME> LIKE 'domxfercode';
\""

# Count records
ssh permtrak2@permtrak.com "mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox -e \"
SELECT 
    (SELECT COUNT(*) FROM t_e_s_t_p_e_r_m) AS testperm_count,
    (SELECT COUNT(*) FROM p_w_d) AS pwd_count,
    (SELECT COUNT(*) FROM c_stripetrx) AS stripetrx_count;
\""
```

---

### Step 5: Test Changes **[espocrm] [wordpress-reports]**

**A. Test EspoCRM UI** **[espocrm]**
1. Open record in private browser tab
2. Verify `statdomain` shows "Transfer" option
3. Enter test data in `domxfercode` field
4. Save and reload record
5. Verify data persists

**B. Test WordPress Report** **[wordpress-reports]**
1. Open domain management report: `https://rpx-sb.permtrak.com/domain-management/`
2. Verify styling improvements render correctly
3. Verify `domxfercode` column displays
4. Check data from EspoCRM appears correctly
5. Test report performance (load time)

**C. Check Logs**
```bash
# EspoCRM logs [espocrm]
ssh permtrak2@permtrak.com "tail -n 50 /home/permtrak2/sandbox.permtrak.com/EspoCRM/data/logs/espo-*.log"

# WordPress PHP errors [wordpress-reports]
ssh permtrak2@permtrak.com "tail -n 50 /home/permtrak2/rpx-sb.permtrak.com/error_log"
```

---

### Step 6: Create Golden Image V8 **[espocrm]**

**After Successful Testing:**

```bash
# A. Create EspoCRM tar archive [espocrm]
ssh permtrak2@permtrak.com "cd /home/permtrak2/backups && \
    tar -czf espo-sandbox-golden-v8-domain-mgmt-2025-11-10.tar.gz \
    /home/permtrak2/sandbox.permtrak.com/EspoCRM"

# B. Create database dump [mysql data sync]
ssh permtrak2@permtrak.com "mysqldump -u permtrak2_sandbox \
    -p'XTz5*]xF-Zx4=Lx-u' \
    --single-transaction \
    permtrak2_sandbox > /home/permtrak2/backups/espo-sandbox-golden-v8-domain-mgmt-2025-11-10.sql"

# C. Create GitHub branch [espocrm]
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-sandbox"
git checkout -b golden-v8-domain-mgmt-2025-11-10
git add .
git commit -m "[espocrm] Golden Image V8: Domain management entity build-out complete"
git push origin golden-v8-domain-mgmt-2025-11-10

# D. Tag main branch
git checkout main
git tag -a v8-domain-mgmt -m "Golden Image V8: Domain management entity with domxfercode field"
git push origin v8-domain-mgmt
```

**WordPress Golden Image (First One!)** **[wordpress-reports]**

```bash
# A. Create WordPress tar archive [wordpress-reports]
ssh permtrak2@permtrak.com "cd /home/permtrak2/backups && \
    tar -czf wp-sandbox-golden-v1-domain-report-2025-11-10.tar.gz \
    /home/permtrak2/rpx-sb.permtrak.com"

# B. Create database dump [mysql data sync]
ssh permtrak2@permtrak.com "mysqldump -u permtrak2_rpxsb \
    -p'FDv6Ug#G&hH?3ypf' \
    --single-transaction \
    permtrak2_rpxsb > /home/permtrak2/backups/wp-sandbox-golden-v1-domain-report-2025-11-10.sql"

# C. Commit to GitHub [wordpress-reports]
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/3-REPORTS/WORDPRESS-AUTOMATION/reports-sb"
git add .
git commit -m "[wordpress-reports] Golden Image V1: Enhanced domain management report"
git push origin main
```

---

## 📋 Phase Line Bravo: Stripe Transaction Mapper Integration

**Goal:** Test Stripe transaction mapper with fresh production data in c_stripetrx table

**Prerequisites:**
- ✅ Phase Line Alpha completed
- ✅ Fresh prod data imported to sandbox
- ✅ Stripe transaction mapper script exists (from other AI box)

### Step 1: Verify c_stripetrx Table **[espocrm]**

```bash
# Check table status
ssh permtrak2@permtrak.com "mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox -e \"
SELECT 
    COUNT(*) AS total_records,
    COUNT(perm_id) AS mapped_records,
    COUNT(*) - COUNT(perm_id) AS unmapped_records
FROM c_stripetrx;
\""
```

**Expected State:**
- If imported from prod: `perm_id` will be NULL for all records (prod doesn't have this field)
- If kept sandbox data: Some records may already have `perm_id` populated from previous testing

---

### Step 2: Run Stripe Transaction Mapper **[external script]**

**Location:** Other AI box (separate environment)

**What It Does:**
1. Reads Stripe transaction descriptions from `c_stripetrx`
2. Data mines case numbers from descriptions
3. Populates `perm_id` field with matching TESTPERM record IDs
4. Creates relationship between Stripe transactions and PERM cases

**Example Mapping:**
```
Stripe Description: "PERM Case #12345 - Payment for Acme Corp"
↓ (data mining)
Case Number: 12345
↓ (lookup in TESTPERM)
perm_id: 68f8e51c8bf7dac8f
```

---

### Step 3: Verify Mapping Results **[espocrm]**

```bash
# Check mapping success rate
ssh permtrak2@permtrak.com "mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox -e \"
SELECT 
    COUNT(*) AS total_records,
    COUNT(perm_id) AS mapped_records,
    ROUND(COUNT(perm_id) / COUNT(*) * 100, 2) AS mapping_rate_pct
FROM c_stripetrx;
\""

# Verify specific mapping
ssh permtrak2@permtrak.com "mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox -e \"
SELECT 
    s.id,
    s.casenumber,
    s.perm_id,
    p.name AS case_name
FROM c_stripetrx s
LEFT JOIN t_e_s_t_p_e_r_m p ON s.perm_id = p.id
LIMIT 10;
\""
```

---

### Step 4: Test in EspoCRM UI **[espocrm]**

1. Open CStripetrx record: `https://sandbox.permtrak.com/EspoCRM/#CStripetrx/view/<ID>`
2. Verify `perm` relationship dropdown shows linked TESTPERM record
3. Click through to TESTPERM record
4. Verify relationship is bidirectional

---

### Step 5: Update WordPress Stripe Report **[wordpress-reports]**

**File:** `/reports-sb/widgets/stripe-trx-report.php`

**Changes:**
```php
// Add to SELECT query (around line 159-180)
s.perm_id,
p.name AS case_name

// Add to JOIN (after existing JOINs)
LEFT JOIN t_e_s_t_p_e_r_m p ON s.perm_id = p.id

// Add to table headers (around line 245-252)
<th>Case #</th>

// Add to table row display (around line 334-383)
<td>
    <?php if ($row['perm_id']): ?>
        <a href="https://sandbox.permtrak.com/EspoCRM/#TESTPERM/view/<?php echo $row['perm_id']; ?>" target="_blank">
            <?php echo htmlspecialchars($row['case_name']); ?>
        </a>
    <?php else: ?>
        <span class="text-muted">Not Mapped</span>
    <?php endif; ?>
</td>
```

---

### Step 6: Test WordPress Report **[wordpress-reports]**

1. Open Stripe transaction report: `https://rpx-sb.permtrak.com/stripe-transactions/`
2. Verify "Case #" column appears
3. Verify case names display correctly
4. Click case links → should open EspoCRM record in new tab
5. Check unmapped transactions show "Not Mapped"

---

### Step 7: Create Golden Image V9 **[espocrm] [wordpress-reports]**

**After Successful Stripe Mapping:**

```bash
# EspoCRM Golden Image V9 [espocrm]
ssh permtrak2@permtrak.com "cd /home/permtrak2/backups && \
    tar -czf espo-sandbox-golden-v9-stripe-mapping-2025-11-10.tar.gz \
    /home/permtrak2/sandbox.permtrak.com/EspoCRM && \
    mysqldump -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' --single-transaction \
    permtrak2_sandbox > espo-sandbox-golden-v9-stripe-mapping-2025-11-10.sql"

# WordPress Golden Image V2 [wordpress-reports]
ssh permtrak2@permtrak.com "cd /home/permtrak2/backups && \
    tar -czf wp-sandbox-golden-v2-stripe-report-2025-11-10.tar.gz \
    /home/permtrak2/rpx-sb.permtrak.com && \
    mysqldump -u permtrak2_rpxsb -p'FDv6Ug#G&hH?3ypf' --single-transaction \
    permtrak2_rpxsb > wp-sandbox-golden-v2-stripe-report-2025-11-10.sql"
```

---

## 📋 Phase Line Charlie: Migrate to Dev Environment

**Goal:** Clone sandbox → dev, enable caching, test in dev environment

**Prerequisites:**
- ✅ Phase Line Alpha completed
- ✅ Phase Line Bravo completed
- ✅ All testing successful in sandbox
- ✅ Golden Images V8 & V9 created

---

### Step 1: Clone EspoCRM from Sandbox to Dev **[espocrm]**

**Note:** Dev currently has old data. This will replace it with optimized sandbox build.

```bash
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-ctl"

# Run sandbox-to-dev clone script (if exists)
# OR manually via SSH:

# A. Backup existing dev
ssh permtrak2@permtrak.com "cd /home/permtrak2 && \
    tar -czf backups/dev-backup-before-sandbox-clone-2025-11-10.tar.gz dev.permtrak.com/EspoCRM"

# B. Export sandbox database [mysql data sync]
ssh permtrak2@permtrak.com "mysqldump -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' \
    --single-transaction permtrak2_sandbox > /tmp/sandbox_to_dev.sql"

# C. Rsync files [espocrm]
ssh permtrak2@permtrak.com "rsync -av --delete \
    --exclude='data/cache' --exclude='data/logs' \
    /home/permtrak2/sandbox.permtrak.com/EspoCRM/ \
    /home/permtrak2/dev.permtrak.com/EspoCRM/"

# D. Import database [mysql data sync]
ssh permtrak2@permtrak.com "mysql -u permtrak2_dev -p'xX-6x8-Wcx6y8-9hjJFe44VhA-Xx' \
    -e 'DROP DATABASE IF EXISTS permtrak2_dev; CREATE DATABASE permtrak2_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;' && \
    mysql -u permtrak2_dev -p'xX-6x8-Wcx6y8-9hjJFe44VhA-Xx' permtrak2_dev < /tmp/sandbox_to_dev.sql"

# E. Update config.php [espocrm]
ssh permtrak2@permtrak.com "cd /home/permtrak2/dev.permtrak.com/EspoCRM && \
    php -r \"
    \\\$config = include 'data/config.php';
    \\\$config['database']['dbname'] = 'permtrak2_dev';
    \\\$config['database']['user'] = 'permtrak2_dev';
    \\\$config['database']['password'] = 'xX-6x8-Wcx6y8-9hjJFe44VhA-Xx';
    \\\$config['siteUrl'] = 'https://dev.permtrak.com/EspoCRM';
    \\\$config['useCache'] = true;  // ENABLE CACHE IN DEV
    file_put_contents('data/config.php', '<?php return ' . var_export(\\\$config, true) . ';');
    \""

# F. Clear cache and rebuild [espocrm]
ssh permtrak2@permtrak.com "cd /home/permtrak2/dev.permtrak.com/EspoCRM && \
    php command.php clear-cache && \
    php command.php rebuild"

# G. Cleanup
ssh permtrak2@permtrak.com "rm /tmp/sandbox_to_dev.sql"
```

---

### Step 2: Clone WordPress from Sandbox to Dev **[wordpress-reports]**

**Current Issue:** rpx-dev was cloned from prod, needs to be re-cloned from rpx-sb

```bash
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/3-REPORTS/WORDPRESS-AUTOMATION/reports-ctl/scripts"

# Re-clone from sandbox [wordpress-reports]
python3 wordpress-clone.py --source rpx-sb.permtrak.com --target rpx-dev.permtrak.com
```

**Then update files:** **[wordpress-reports]**

```bash
# Download to local
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/3-REPORTS/WORDPRESS-AUTOMATION/reports-dev"
scp -r permtrak2@permtrak.com:/home/permtrak2/rpx-dev.permtrak.com/wp-content/themes/genesis/lib/widgets/*.php ./widgets/
scp -r permtrak2@permtrak.com:/home/permtrak2/rpx-dev.permtrak.com/wp-content/uploads/dynamik-gen/theme/*.php ./custom-theme/
```

**Edit custom-functions.php:** Change `sandbox.permtrak.com` → `dev.permtrak.com` **[espocrm]**

**Edit widgets/db.php:** Change to `permtrak2_dev` database **[mysql data sync]**

```php
$con = mysqli_connect("localhost", "permtrak2_dev", "xX-6x8-Wcx6y8-9hjJFe44VhA-Xx", "permtrak2_dev");
```

**Deploy back to server:**

```bash
scp custom-theme/custom-functions.php permtrak2@permtrak.com:/home/permtrak2/rpx-dev.permtrak.com/wp-content/uploads/dynamik-gen/theme/
scp widgets/db.php permtrak2@permtrak.com:/home/permtrak2/rpx-dev.permtrak.com/wp-content/themes/genesis/lib/widgets/
```

---

### Step 3: Test Dev Environment **[espocrm] [wordpress-reports]**

**A. Test EspoCRM Dev** **[espocrm]**
1. Open: `https://dev.permtrak.com/EspoCRM`
2. Verify login works
3. Open TESTPERM record → check `domxfercode` field exists
4. Open CStripetrx record → check `perm` relationship works
5. Check cache is ON: Settings → System
6. Test record save performance (should be faster with cache)

**B. Test WordPress Dev** **[wordpress-reports]**
1. Open: `https://rpx-dev.permtrak.com`
2. Test domain management report
3. Test Stripe transaction report
4. Verify CRM links point to `dev.permtrak.com/EspoCRM`
5. Verify data displays correctly

---

### Step 4: Create Dev Golden Images **[espocrm] [wordpress-reports]**

```bash
# EspoCRM Dev [espocrm]
ssh permtrak2@permtrak.com "cd /home/permtrak2/backups && \
    tar -czf espo-dev-golden-v1-from-sandbox-2025-11-10.tar.gz \
    /home/permtrak2/dev.permtrak.com/EspoCRM && \
    mysqldump -u permtrak2_dev -p'xX-6x8-Wcx6y8-9hjJFe44VhA-Xx' --single-transaction \
    permtrak2_dev > espo-dev-golden-v1-from-sandbox-2025-11-10.sql"

# WordPress Dev [wordpress-reports]
ssh permtrak2@permtrak.com "cd /home/permtrak2/backups && \
    tar -czf wp-dev-golden-v1-from-sandbox-2025-11-10.tar.gz \
    /home/permtrak2/rpx-dev.permtrak.com && \
    mysqldump -u permtrak2_rpxdev -p'XTz5*]xF-Zx4=Lx-u' --single-transaction \
    permtrak2_rpxdev > wp-dev-golden-v1-from-sandbox-2025-11-10.sql"
```

---

## 📊 Success Criteria

### Phase Line Alpha
- ✅ `statdomain` ENUM has "Transfer" value
- ✅ `domxfercode` field exists and functional
- ✅ WordPress domain report enhanced and displaying correctly
- ✅ Fresh prod data imported successfully
- ✅ No data loss or corruption
- ✅ Golden Image V8 created

### Phase Line Bravo
- ✅ Stripe transaction mapper successfully populates `perm_id`
- ✅ CStripetrx → TESTPERM relationship working in EspoCRM
- ✅ WordPress Stripe report displays case links
- ✅ Golden Image V9 created

### Phase Line Charlie
- ✅ EspoCRM cloned sandbox → dev with cache enabled
- ✅ WordPress cloned sandbox → dev with correct integration
- ✅ All functionality works in dev environment
- ✅ Dev golden images created
- ✅ Ready to progress to staging testing

---

## 🔄 Workflow Summary

```
┌──────────────────────────────────────────────────────────────┐
│ PHASE LINE ALPHA: Domain Management Build-Out               │
│ [espocrm] Edit Entity → Rebuild → [wordpress-reports] Edit  │
│ → [mysql data sync] Import Fresh Data → Test                │
│ → Golden Image V8                                            │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│ PHASE LINE BRAVO: Stripe Transaction Mapper                 │
│ Run Mapper → Verify Mappings → Update WP Report → Test      │
│ → Golden Image V9                                            │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│ PHASE LINE CHARLIE: Migrate to Dev                          │
│ Clone Sandbox → Dev → Enable Caching → Test                 │
│ → Dev Golden Images → Ready for Staging                     │
└──────────────────────────────────────────────────────────────┘
```

---

## 📋 Phase Line Delta: PWD Extractor Integration

**Goal:** Test PWD Extractor tool in sandbox, validate data import to PWD entity, migrate through environments

**Prerequisites:**
- ✅ Phase Line Charlie completed
- ✅ PWD entity optimized and stable in sandbox
- ✅ PWD Extractor repo ready

---

### Overview **[pwd-extractor] [espocrm]**

**PWD Extractor** is a separate tool/repo that extracts PWD (Prevailing Wage Determination) data and imports it into the EspoCRM PWD entity.

**Previous Workflow (Risky):**
```
PWD Extractor → PROD directly ⚠️ DANGEROUS
```

**New Workflow (Safe):**
```
PWD Extractor → Sandbox → Test → Dev → Staging → Prod
```

**Repository Location:**
- Separate repo: `/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/PWD-EXTRACTOR` **[pwd-extractor]**
- GitHub: (specify repo URL if exists)

---

### Step 1: Prepare Sandbox for PWD Import **[espocrm]**

**A. Verify PWD Entity Status**

```bash
# Check PWD table structure [espocrm]
ssh permtrak2@permtrak.com "mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox -e \"
DESCRIBE p_w_d;
\""

# Check current row size [espocrm]
ssh permtrak2@permtrak.com "mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox -e \"
SELECT 
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb,
    table_rows
FROM information_schema.tables
WHERE table_schema = 'permtrak2_sandbox' 
AND table_name = 'p_w_d';
\""

# Check existing record count
ssh permtrak2@permtrak.com "mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox -e \"
SELECT COUNT(*) AS pwd_record_count FROM p_w_d;
\""
```

**B. Backup Current PWD Data** **[mysql data sync]**

```bash
# Export current PWD table (safety backup)
ssh permtrak2@permtrak.com "mysqldump -u permtrak2_sandbox \
    -p'XTz5*]xF-Zx4=Lx-u' \
    --single-transaction \
    permtrak2_sandbox p_w_d > /tmp/pwd_backup_before_extractor_test.sql"

# Copy to backups directory
ssh permtrak2@permtrak.com "mv /tmp/pwd_backup_before_extractor_test.sql \
    /home/permtrak2/backups/pwd_backup_before_extractor_test_2025-11-10.sql"
```

---

### Step 2: Configure PWD Extractor for Sandbox **[pwd-extractor]**

**A. Update Database Connection Settings** **[pwd-extractor]**

Edit PWD Extractor config to point to sandbox:

```python
# config.py or similar
DB_CONFIG = {
    'host': 'permtrak.com',
    'user': 'permtrak2_sandbox',
    'password': 'XTz5*]xF-Zx4=Lx-u',
    'database': 'permtrak2_sandbox',
    'table': 'p_w_d'
}

# API endpoint (if using EspoCRM API)
ESPO_URL = 'https://sandbox.permtrak.com/EspoCRM'
ESPO_API_KEY = '<sandbox_api_key>'
```

**B. Set Import Mode** **[pwd-extractor]**

```python
# Test mode - import limited records first
TEST_MODE = True
MAX_TEST_RECORDS = 10  # Start with 10 records for validation

# Later, for full import
# TEST_MODE = False
```

---

### Step 3: Run PWD Extractor Test Import **[pwd-extractor]**

**A. Execute Test Run** **[pwd-extractor]**

```bash
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/PWD-EXTRACTOR"

# Run in test mode (10 records)
python3 pwd_extractor.py --mode test --target sandbox --limit 10
```

**B. Verify Test Import** **[espocrm]**

```bash
# Check new records in sandbox
ssh permtrak2@permtrak.com "mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox -e \"
SELECT 
    id,
    name,
    created_at,
    DATE(created_at) AS import_date
FROM p_w_d
ORDER BY created_at DESC
LIMIT 10;
\""

# Verify field population
ssh permtrak2@permtrak.com "mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox -e \"
SELECT 
    COUNT(*) AS total,
    COUNT(DISTINCT name) AS unique_names,
    COUNT(DISTINCT datereceived) AS with_date_received,
    COUNT(DISTINCT visatype) AS with_visa_type
FROM p_w_d
WHERE DATE(created_at) = CURDATE();
\""
```

**C. Test in EspoCRM UI** **[espocrm]**

1. Open: `https://sandbox.permtrak.com/EspoCRM/#PWD`
2. Find newly imported records (sort by Created Date DESC)
3. Open a test record
4. Verify all fields populated correctly:
   - Name, dates, ENUM values (statcase, visatype, etc.)
   - Address fields, employer info
   - All optimized TEXT and VARCHAR fields
5. Test record save/edit
6. Check for any validation errors

---

### Step 4: Full Import Test **[pwd-extractor] [espocrm]**

**After Test Records Validated:**

```bash
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/PWD-EXTRACTOR"

# Run full import
python3 pwd_extractor.py --mode full --target sandbox
```

**Monitor Import Progress:**

```bash
# Watch record count in real-time
watch -n 5 "ssh permtrak2@permtrak.com \"mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox -e 'SELECT COUNT(*) AS total FROM p_w_d;'\""

# Check for errors in PWD Extractor log
tail -f /path/to/pwd_extractor.log
```

---

### Step 5: Validate Full Import **[espocrm]**

**A. Data Integrity Checks** **[mysql data sync]**

```bash
# Check for NULL critical fields
ssh permtrak2@permtrak.com "mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox -e \"
SELECT 
    COUNT(*) AS total_records,
    COUNT(name) AS with_name,
    COUNT(*) - COUNT(name) AS missing_name,
    COUNT(datereceived) AS with_date_received,
    COUNT(visatype) AS with_visa_type
FROM p_w_d;
\""

# Check for duplicate records
ssh permtrak2@permtrak.com "mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox -e \"
SELECT 
    name, 
    COUNT(*) AS duplicate_count
FROM p_w_d
GROUP BY name
HAVING COUNT(*) > 1
LIMIT 20;
\""

# Verify row size still healthy [espocrm]
ssh permtrak2@permtrak.com "mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox -e \"
SELECT 
    table_name,
    ROUND(AVG(LENGTH(CONCAT_WS('',
        COALESCE(name,''),
        COALESCE(datereceived,''),
        COALESCE(visatype,'')
    ))) / 8126 * 100, 2) AS estimated_row_pct
FROM information_schema.tables
WHERE table_schema = 'permtrak2_sandbox' 
AND table_name = 'p_w_d';
\""
```

**B. EspoCRM UI Testing** **[espocrm]**

1. Browse PWD list view - check performance
2. Test search functionality
3. Test filters (by status, visa type, date)
4. Open multiple records - verify data accuracy
5. Test record creation manually (ensure import didn't break UI)
6. Check EspoCRM logs for errors:

```bash
ssh permtrak2@permtrak.com "tail -n 100 /home/permtrak2/sandbox.permtrak.com/EspoCRM/data/logs/espo-*.log | grep -i error"
```

---

### Step 6: Test WordPress PWD Report **[wordpress-reports]**

**If PWD report exists in WordPress:**

1. Open: `https://rpx-sb.permtrak.com/pwd-report/`
2. Verify newly imported PWD records display
3. Check report filters work with new data
4. Test report export functionality
5. Verify CRM links to PWD records work

---

### Step 7: Post-Import Cleanup **[espocrm]**

**A. Run Rebuild** **[espocrm]**

```bash
# Clear cache and rebuild to optimize indexes
ssh permtrak2@permtrak.com "cd /home/permtrak2/sandbox.permtrak.com/EspoCRM && \
    php command.php clear-cache && \
    php command.php rebuild"
```

**B. Optimize Database Tables** **[mysql data sync]**

```bash
# Optimize PWD table after bulk insert
ssh permtrak2@permtrak.com "mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox -e \"
OPTIMIZE TABLE p_w_d;
\""
```

---

### Step 8: Create Golden Image V10 **[espocrm] [pwd-extractor]**

**After Successful PWD Import:**

```bash
# A. EspoCRM Sandbox Golden Image V10 [espocrm]
ssh permtrak2@permtrak.com "cd /home/permtrak2/backups && \
    tar -czf espo-sandbox-golden-v10-pwd-extractor-2025-11-10.tar.gz \
    /home/permtrak2/sandbox.permtrak.com/EspoCRM && \
    mysqldump -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' --single-transaction \
    permtrak2_sandbox > espo-sandbox-golden-v10-pwd-extractor-2025-11-10.sql"

# B. Commit PWD Extractor config to repo [pwd-extractor]
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/PWD-EXTRACTOR"
git add config.py  # or whatever config file
git commit -m "[pwd-extractor] Tested successfully in sandbox - ready for dev"
git push origin main

# C. Tag the working version
git tag -a v1.0-sandbox-tested -m "PWD Extractor v1.0 - Sandbox tested and validated"
git push origin v1.0-sandbox-tested
```

---

### Step 9: Deploy to Dev Environment **[pwd-extractor] [espocrm]**

**Prerequisites:**
- ✅ Sandbox testing 100% successful
- ✅ Golden Image V10 created
- ✅ Dev environment ready (from Phase Line Charlie)

**A. Configure PWD Extractor for Dev** **[pwd-extractor]**

```python
# config-dev.py
DB_CONFIG = {
    'host': 'permtrak.com',
    'user': 'permtrak2_dev',
    'password': 'xX-6x8-Wcx6y8-9hjJFe44VhA-Xx',
    'database': 'permtrak2_dev',
    'table': 'p_w_d'
}

ESPO_URL = 'https://dev.permtrak.com/EspoCRM'
ESPO_API_KEY = '<dev_api_key>'
```

**B. Backup Dev PWD Data** **[mysql data sync]**

```bash
ssh permtrak2@permtrak.com "mysqldump -u permtrak2_dev \
    -p'xX-6x8-Wcx6y8-9hjJFe44VhA-Xx' \
    --single-transaction \
    permtrak2_dev p_w_d > /home/permtrak2/backups/pwd_dev_backup_before_extractor_2025-11-10.sql"
```

**C. Run PWD Extractor Against Dev** **[pwd-extractor]**

```bash
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/PWD-EXTRACTOR"

# Test run first (10 records)
python3 pwd_extractor.py --config config-dev.py --mode test --limit 10

# If successful, full run
python3 pwd_extractor.py --config config-dev.py --mode full
```

**D. Validate Dev Import** **[espocrm]**

```bash
# Same validation queries as Step 5, but against permtrak2_dev

# Test in Dev UI with CACHING ENABLED
# https://dev.permtrak.com/EspoCRM/#PWD
# Performance should be BETTER with cache on
```

**E. Create Dev Golden Image V2** **[espocrm]**

```bash
ssh permtrak2@permtrak.com "cd /home/permtrak2/backups && \
    tar -czf espo-dev-golden-v2-pwd-extractor-2025-11-10.tar.gz \
    /home/permtrak2/dev.permtrak.com/EspoCRM && \
    mysqldump -u permtrak2_dev -p'xX-6x8-Wcx6y8-9hjJFe44VhA-Xx' --single-transaction \
    permtrak2_dev > espo-dev-golden-v2-pwd-extractor-2025-11-10.sql"
```

---

### Step 10: Deploy to Staging **[pwd-extractor] [espocrm]**

**Follow same process as Dev, but with staging credentials:**

```python
# config-staging.py
DB_CONFIG = {
    'host': 'permtrak.com',
    'user': 'permtrak2_staging',
    'password': 'xX-6x8-Wcx6y8-9hjJFe44VhA-Xx',
    'database': 'permtrak2_staging',
    'table': 'p_w_d'
}

ESPO_URL = 'https://staging.permtrak.com/EspoCRM'
```

**Staging validation includes:**
- Performance testing with cache ON
- UAT by stakeholders
- Verify WordPress reports in staging
- Load testing if needed

---

### Step 11: Deploy to Production **[pwd-extractor] [espocrm]**

**⚠️ CRITICAL: Only after ALL testing successful**

**A. Final Pre-Production Checklist**
- ✅ Sandbox testing passed
- ✅ Dev testing passed
- ✅ Staging UAT passed
- ✅ All golden images created
- ✅ Rollback plan documented
- ✅ Production backup created

**B. Production Backup** **[mysql data sync]**

```bash
# CRITICAL: Backup prod PWD table before ANY changes
ssh permtrak2@permtrak.com "mysqldump -u permtrak2_prod \
    -p'xX-6x8-Wcx6y8-9hjJFe44VhA-Xx' \
    --single-transaction \
    permtrak2_prod p_w_d > /home/permtrak2/backups/pwd_prod_backup_before_extractor_2025-11-10.sql"
```

**C. Configure for Production** **[pwd-extractor]**

```python
# config-prod.py
DB_CONFIG = {
    'host': 'permtrak.com',
    'user': 'permtrak2_prod',
    'password': 'xX-6x8-Wcx6y8-9hjJFe44VhA-Xx',
    'database': 'permtrak2_prod',
    'table': 'p_w_d'
}

ESPO_URL = 'https://prod.permtrak.com/EspoCRM'

# Production safety settings
DRY_RUN = True  # Test first!
BACKUP_BEFORE_IMPORT = True
ROLLBACK_ON_ERROR = True
```

**D. Execute Production Import** **[pwd-extractor]**

```bash
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/PWD-EXTRACTOR"

# DRY RUN FIRST
python3 pwd_extractor.py --config config-prod.py --dry-run

# If dry run successful, real run
python3 pwd_extractor.py --config config-prod.py --mode full
```

**E. Validate Production** **[espocrm]**

- Immediate verification of record counts
- Check critical fields populated
- Test live WordPress reports
- Monitor EspoCRM logs for 24 hours
- User acceptance testing

---

## 📊 Success Criteria - Phase Line Delta

### Sandbox Testing
- ✅ PWD Extractor successfully imports test records (10)
- ✅ PWD Extractor successfully imports full dataset
- ✅ No data integrity issues detected
- ✅ PWD entity row size remains healthy (<45%)
- ✅ EspoCRM UI performs well with new data
- ✅ WordPress PWD report displays correctly
- ✅ Golden Image V10 created

### Dev Testing
- ✅ PWD Extractor works with dev database
- ✅ Cache enabled - performance validated
- ✅ Data integrity maintained
- ✅ Dev Golden Image V2 created

### Staging Testing
- ✅ UAT passed by stakeholders
- ✅ Load testing passed (if applicable)
- ✅ WordPress reports validated
- ✅ Staging golden image created

### Production Deployment
- ✅ Production backup created
- ✅ PWD Extractor runs successfully in prod
- ✅ No errors or data loss
- ✅ Live WordPress reports working
- ✅ User acceptance confirmed

---

## 🔄 Workflow Summary - All Phases

```
┌──────────────────────────────────────────────────────────────┐
│ PHASE LINE ALPHA: Domain Management Build-Out               │
│ [espocrm] Entity edits + [wordpress-reports] UI + Fresh Data│
│ → Golden Image V8                                            │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│ PHASE LINE BRAVO: Stripe Transaction Mapper                 │
│ [external] Mapper + [espocrm] Relations + [wordpress] UI    │
│ → Golden Image V9                                            │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│ PHASE LINE CHARLIE: Migrate to Dev                          │
│ Clone Sandbox → Dev + Enable Caching + Test                 │
│ → Dev Golden Images V1                                       │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│ PHASE LINE DELTA: PWD Extractor Integration                 │
│ [pwd-extractor] Test in Sandbox → Dev → Staging → Prod      │
│ → Golden Image V10 + Dev V2 + Staging V1 + Prod Validated   │
└──────────────────────────────────────────────────────────────┘
```

---

## 📝 Notes

- **[espocrm]** Working in Sandbox with cache OFF allows safe Entity Manager testing
- **[wordpress-reports]** WordPress reports query EspoCRM database directly (tight integration)
- **[mysql data sync]** Fresh data imports critical for realistic testing
- **[pwd-extractor]** Separate repo/tool - configured per environment
- **Golden Images** created after each successful phase for rollback capability
- **Learning-focused workflow** - Master in Sandbox before progressing to Dev → Staging → Prod
- **Production safety** - ALWAYS backup before changes, ALWAYS test dry-run first

---

## 🔗 Related Documentation

- `/docs/quick-reference-wp-espo-automations.md` - Full infrastructure reference
- `/espo-sandbox/docs/` - Sandbox experiment logs & golden images
- `/reports-sb/` - WordPress sandbox files & widgets
- `/PWD-EXTRACTOR/` - PWD Extractor tool & configs **[pwd-extractor]**

