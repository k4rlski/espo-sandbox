# 🗑️ EspoCRM Field Deletion Procedure

**Proven workflow for safe, complete field deletion from TESTPERM entity**

**Status:** ✅ Validated on sandbox.permtrak.com  
**First Success:** dateinvoicedlocal field (Nov 3, 2025)

---

## ⚠️ Prerequisites

Before starting ANY field deletion:

- [ ] Sandbox environment ready (cache disabled)
- [ ] Current golden image exists (restore point)
- [ ] Field confirmed unused (check data, check reports)
- [ ] Field name identified in Entity Manager
- [ ] Field location identified in Layout Manager

---

## 📋 3-STEP DELETION WORKFLOW

### Step 1: Entity Manager Deletion
**Purpose:** Remove field definition from metadata

```
1. Navigate to: https://sandbox.permtrak.com/EspoCRM/#Admin/entityManager
2. Click: TESTPERM entity
3. Click: Fields tab
4. Find target field in list
5. Click: Trash icon (🗑️) on the right
6. Click: Confirm on popup
7. Verify: Green success message appears
8. Result: Field removed from entityDefs/TESTPERM.json
```

**What this does:**
- ✅ Removes field from JSON metadata
- ❌ Does NOT remove from layouts
- ❌ Does NOT drop database column

---

### Step 2: Layout Manager Removal
**Purpose:** Remove field from all UI layouts

```
1. Navigate to: https://sandbox.permtrak.com/EspoCRM/#Admin/layouts
2. Select: TESTPERM entity
3. Select: Detail layout
4. Find field in layout (left side)
5. Click: X symbol on field
   OR: Drag field to "Available Fields" panel (right side)
6. Click: Save button
7. Verify: Success message appears
8. Repeat for List layout if field present there
```

**What this does:**
- ✅ Removes field from detail/list layouts
- ✅ Eliminates "zombie field" appearance
- ✅ Enables rebuild --hard to drop DB column

**CRITICAL:** Must complete this step for database cleanup!

---

### Step 3: Rebuild --hard
**Purpose:** Clear cache and drop database column

```bash
# SSH to server
ssh permtrak2@permtrak.com

# Navigate to EspoCRM
cd /home/permtrak2/sandbox.permtrak.com/EspoCRM

# Clear cache manually
rm -rf data/cache/*

# Rebuild (regenerate metadata cache)
php rebuild.php

# Rebuild --hard (drop unused columns)
php rebuild.php --hard
```

**What this does:**
- ✅ Clears all caches
- ✅ Regenerates metadata
- ✅ **Automatically drops database column** (when steps 1 & 2 complete)

**Expected output:**
```
Rebuild has been done.
```

---

## ✅ Verification Checklist

After completing all 3 steps:

### Database Verification
```bash
ssh permtrak2@permtrak.com
mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox

# Check if column exists
SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 't_e_s_t_p_e_r_m' 
  AND COLUMN_NAME = 'fieldname';

# Result should be empty (no rows)
```

### UI Verification
```
1. Open TESTPERM list view
2. Verify field not in columns
3. Open any TESTPERM record
4. Verify field not visible in detail view
5. Edit record, change a value, save
6. Verify no errors (especially Error 500)
```

### File Verification
```bash
# Check entityDefs (should NOT contain field)
grep -i "fieldname" custom/Espo/Custom/Resources/metadata/entityDefs/TESTPERM.json

# Check layouts (should NOT contain field)
grep -i "fieldname" custom/Espo/Custom/Resources/layouts/TESTPERM/detail.json
```

**All checks should return empty/no results** ✅

---

## 📦 Post-Deletion: Create Golden Image

After successful deletion and verification:

```bash
# SSH to server
ssh permtrak2@permtrak.com
cd /home/permtrak2/sandbox.permtrak.com

# Create dated golden image
TIMESTAMP=$(date +%Y-%m-%d-%H%M)

# Tar archive (excludes cache/logs/uploads)
tar -czf snapshots/sandbox-golden-${TIMESTAMP}.tar.gz \
    --exclude='EspoCRM/data/cache/*' \
    --exclude='EspoCRM/data/logs/*' \
    --exclude='EspoCRM/data/upload/*' \
    EspoCRM/

# Database dump
mysqldump -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' \
    --single-transaction \
    --quick \
    --lock-tables=false \
    permtrak2_sandbox | gzip > snapshots/sandbox-db-golden-${TIMESTAMP}.sql.gz

# Verify
ls -lh snapshots/sandbox-golden-${TIMESTAMP}.tar.gz
ls -lh snapshots/sandbox-db-golden-${TIMESTAMP}.sql.gz
```

---

## 🌐 Git Branch & Commit

After creating golden image:

```bash
# Local machine
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-sandbox"

# Create new branch (numbered sequence)
git checkout -b field-deletion-02-[fieldname]

# Add experiment documentation
git add docs/EXPERIMENT-00X-[fieldname]-SUCCESS.md

# Commit with detailed message
git commit -m "🗑️ Field Deletion #X: [fieldname] removed successfully

Field: [fieldname]
Type: [date/varchar/text/etc]
Entity: TESTPERM

Workflow:
  ✅ Step 1: Entity Manager deletion
  ✅ Step 2: Layout Manager removal
  ✅ Step 3: rebuild --hard
  ✅ Database column dropped automatically

Verification:
  ✅ Field removed from JSON
  ✅ Field removed from layouts
  ✅ Column dropped from database
  ✅ Records open/save correctly
  ✅ No errors

Golden Image: sandbox-golden-[timestamp]
Branch: field-deletion-0X-[fieldname]"

# Push to GitHub
git push -u origin field-deletion-02-[fieldname]
```

---

## 📊 Field Deletion Log

Maintain running log of all deleted fields:

```markdown
# Field Deletion Log - TESTPERM Entity

| # | Date | Field Name | Type | Golden Image | Git Branch | Status |
|---|------|------------|------|--------------|------------|--------|
| 01 | 2025-11-03 | dateinvoicedlocal | date | 2025-11-03-2311 | field-deletion-01-dateinvoicedlocal | ✅ Success |
| 02 | YYYY-MM-DD | fieldname | type | timestamp | branch-name | ✅ Success |
```

---

## ⚠️ Common Issues & Solutions

### Issue 1: "Zombie Field" Appears in UI
**Symptom:** Field shows in UI but doesn't work (no dropdown, broken UI)  
**Cause:** Completed step 1, but not step 2  
**Solution:** Complete step 2 (Layout Manager removal)

### Issue 2: Database Column Won't Drop
**Symptom:** Column still exists after rebuild --hard  
**Cause:** Field still in layout files  
**Solution:** Check ALL layouts (detail, list, etc.) and remove field

### Issue 3: Error 500 When Opening Records
**Symptom:** Records won't open, Error 500 in console  
**Cause:** Layout references field that no longer exists in metadata  
**Solution:** Remove field from layouts OR restore field to metadata temporarily

### Issue 4: rebuild --hard Fails
**Symptom:** rebuild.php --hard exits with error  
**Cause:** Various (row size, index issues, etc.)  
**Solution:** Check data/logs/espo.log for specific error, address root cause

---

## 🎯 Success Criteria

A field deletion is successful when:

- ✅ Field NOT in entityDefs/TESTPERM.json
- ✅ Field NOT in any layout files
- ✅ Column NOT in database
- ✅ Records open without errors
- ✅ Records save successfully
- ✅ UI renders cleanly
- ✅ Golden image created
- ✅ Git branch committed and pushed
- ✅ Documentation complete

---

## 📈 Expected Impact

Per field deleted:
- Row size: Reduced by field's byte size
- Database: Column removed, space reclaimed
- Metadata: JSON smaller, faster parsing
- UI: Cleaner, less cluttered
- Performance: Marginal improvement per field

After deleting 10+ unused fields:
- Row size: Noticeably smaller
- Database: Significant space reclaim
- Metadata: Faster loading
- UI: Much cleaner
- Performance: Measurable improvement

---

## 🚀 Batch Deletion Strategy

For multiple fields:

1. Delete one field at a time (don't rush)
2. Test after each deletion
3. Create golden image after each success
4. Git branch for each field (traceability)
5. Update field deletion log
6. Move to next field

**Why one at a time?**
- Easier to rollback if issues
- Clearer git history
- Pinpoint problem fields
- Reduces risk
- More golden images (more restore points)

---

## 📝 Next Field Candidates

From earlier analysis, these fields are safe to delete:

| Field Name | Type | Data Present | Priority | Notes |
|------------|------|--------------|----------|-------|
| adtextnews2 | text | 0% | High | Ad text, unused |
| quoterequestnotes | text | 0% | High | Quote notes, unused |
| [Identify more via forensic analysis] | | | | |

**Before deleting, always:**
1. Verify 0% usage in database
2. Check WordPress reports don't use it
3. Confirm with stakeholders if business-critical

---

## 🎓 Key Learnings

1. **All 3 steps required** for complete deletion
2. **Layout removal is critical** - enables DB cleanup
3. **rebuild --hard is smart** - only drops when safe
4. **No manual SQL needed** - EspoCRM handles it
5. **One field at a time** - safer, more traceable
6. **Golden images critical** - enable instant rollback
7. **Cache disabled OK** - basic ops work fine

---

**This procedure has been validated and proven safe on sandbox.permtrak.com. Use it with confidence for systematic field cleanup!** ✅

