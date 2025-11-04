# Golden Image Backup Strategy - Sandbox Stable State

**Date:** November 4, 2025
**State:** Sandbox at 80.3% row size, rebuild-proof, STABLE
**Purpose:** Preserve this critical stable state before risky UI experiments

---

## 🎯 Multi-Layer Backup Approach

We'll create **3 layers of backup** for maximum flexibility:

### Layer 1: Complete Tar Archive (FASTEST FULL RESTORE)
**What:** Full EspoCRM installation folder
**Where:** `/home/permtrak2/snapshots/sandbox-golden-YYYYMMDD-HHMM.tar.gz`
**Restore time:** ~2 minutes
**Use when:** Complete disaster, need instant full restore

### Layer 2: MySQL Database Dump (DATA ONLY)
**What:** Complete database export
**Where:** `/home/permtrak2/snapshots/sandbox-db-golden-YYYYMMDD-HHMM.sql.gz`
**Restore time:** ~5 minutes
**Use when:** Database corruption, need to restore data only

### Layer 3: GitHub Branch (METADATA ONLY)
**What:** All custom metadata (entityDefs, layouts, clientDefs, etc.)
**Where:** `k4rlski/espo-sandbox` → branch `golden-nov4-2025`
**Restore time:** Instant (git checkout)
**Use when:** Need to revert just metadata changes, compare diffs

---

## 📋 Backup Execution Plan

### Step 1: Create Snapshots Directory
```bash
ssh permtrak2@permtrak.com "mkdir -p /home/permtrak2/snapshots"
```

### Step 2: Tar Archive - Full EspoCRM Installation
```bash
TIMESTAMP=$(date +%Y%m%d-%H%M)
ssh permtrak2@permtrak.com "cd /home/permtrak2 && \
    tar --exclude='sandbox.permtrak.com/EspoCRM/data/cache/*' \
        --exclude='sandbox.permtrak.com/EspoCRM/data/logs/*' \
        -czf snapshots/sandbox-golden-${TIMESTAMP}.tar.gz \
        sandbox.permtrak.com/EspoCRM"
```
**Size:** ~50-200MB (without cache/logs)
**Contains:** Code, custom files, config, uploaded files

### Step 3: MySQL Database Dump
```bash
TIMESTAMP=$(date +%Y%m%d-%H%M)
ssh permtrak2@permtrak.com "mysqldump -h localhost \
    -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' \
    --single-transaction --routines --triggers \
    permtrak2_sandbox | gzip > \
    /home/permtrak2/snapshots/sandbox-db-golden-${TIMESTAMP}.sql.gz"
```
**Size:** ~10-100MB (compressed)
**Contains:** All data, schema, row size optimizations

### Step 4: GitHub Branch - Metadata Snapshot
```bash
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-sandbox"
git checkout -b golden-nov4-2025
git add -A
git commit -m "GOLDEN IMAGE: Stable state with 80.3% row size, rebuild-proof"
git push origin golden-nov4-2025
git checkout main
```
**Size:** ~1-5MB
**Contains:** JSON metadata, layouts, custom code definitions

---

## 🔄 Restore Procedures

### Full Restore (Layer 1 + Layer 2)
```bash
# 1. Extract tar archive
ssh permtrak2@permtrak.com "cd /home/permtrak2 && \
    rm -rf sandbox.permtrak.com/EspoCRM.OLD && \
    mv sandbox.permtrak.com/EspoCRM sandbox.permtrak.com/EspoCRM.OLD && \
    tar -xzf snapshots/sandbox-golden-YYYYMMDD-HHMM.tar.gz"

# 2. Restore database
ssh permtrak2@permtrak.com "zcat /home/permtrak2/snapshots/sandbox-db-golden-YYYYMMDD-HHMM.sql.gz | \
    mysql -h localhost -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox"

# 3. Clear cache and rebuild
ssh permtrak2@permtrak.com "cd /home/permtrak2/sandbox.permtrak.com/EspoCRM && \
    php clear_cache.php && php rebuild.php"
```
**Result:** Exact state restored, like time travel

### Metadata-Only Restore (Layer 3)
```bash
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-sandbox"
git checkout golden-nov4-2025
# Copy specific files to server as needed
```
**Result:** Revert just metadata changes, keep current data

### Database-Only Restore (Layer 2)
```bash
ssh permtrak2@permtrak.com "zcat /home/permtrak2/snapshots/sandbox-db-golden-YYYYMMDD-HHMM.sql.gz | \
    mysql -h localhost -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox"
```
**Result:** Restore data and schema, keep current code

---

## 📊 Comparison: Backup Methods

| Method | Full System | Database | Metadata | Restore Speed | Disk Space |
|--------|-------------|----------|----------|---------------|------------|
| **Tar Archive** | ✅ | ✅ | ✅ | ⚡ Fastest | 📦 Medium |
| **MySQL Dump** | ❌ | ✅ | ✅ | ⚡ Fast | 📦 Small |
| **GitHub Branch** | ❌ | ❌ | ✅ | ⚡ Instant | 📦 Tiny |
| **Sister Subdomain** | ✅ | ✅ | ✅ | 🐢 Slow | 📦 Large (2x) |

---

## 🎯 Why This Strategy?

### Layer 1 (Tar) - The "Nuclear Option"
- Complete snapshot of everything
- Instant restore if experiment goes catastrophically wrong
- Self-contained, no dependencies

### Layer 2 (MySQL Dump) - The "Data Safety Net"
- Preserves all your actual data and schema
- Can restore just database if code is fine
- Lightweight, compressed

### Layer 3 (GitHub Branch) - The "Metadata Insurance"
- Version control for all custom definitions
- Can cherry-pick specific changes
- Can diff between golden and experimental states
- Syncs across all your machines

---

## 🚫 Why NOT Sister Subdomain?

**Sister subdomain (like sandbox2.permtrak.com) is overkill because:**
- Uses 2x disk space permanently
- Requires separate SSL cert
- Needs separate database
- More complex to maintain
- Harder to compare changes

**Our 3-layer approach gives you:**
- Same restore capability
- Better granularity (restore just what you need)
- Less ongoing maintenance
- Easier to compare states

---

## ✅ Verification After Backup

After creating backups, verify:
```bash
# Check tar archive exists and size is reasonable
ssh permtrak2@permtrak.com "ls -lh /home/permtrak2/snapshots/sandbox-golden-*.tar.gz"

# Check database dump exists
ssh permtrak2@permtrak.com "ls -lh /home/permtrak2/snapshots/sandbox-db-golden-*.sql.gz"

# Check GitHub branch exists
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-sandbox"
git branch -a | grep golden
```

---

## 📅 Retention Policy

**Golden images (keep indefinitely):**
- This Nov 4 golden image (first stable state)
- Future major milestones

**Experiment backups (keep 7 days):**
- Pre-experiment snapshots
- Delete after confirmed successful

**Daily backups (if implemented, keep 3 days):**
- Automated snapshots
- Rolling retention

---

## 🎯 Next Steps After Backup

Once golden image is secured:

1. ✅ **Proceed with confidence** - You can always restore
2. 🧪 **Experiment freely** - Test Layout Manager, Entity Manager
3. 📝 **Document changes** - Note what works, what doesn't
4. 🔄 **Iterate safely** - If something breaks, restore and try again
5. 🚀 **Graduate to dev** - Once stable, apply learnings to dev.permtrak.com

---

**This is the most careful, segmented approach to preserving your critical stable state.**

