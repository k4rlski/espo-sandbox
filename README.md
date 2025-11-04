# EspoCRM Sandbox Environment

**Purpose:** Safe testing environment for EspoCRM metadata changes, Layout Manager, and Entity Manager experiments

**URL:** https://sandbox.permtrak.com/EspoCRM

**Status:** 🟢 STABLE - Golden image backed up, ready for experiments

---

## 📁 Directory Structure

```
espo-sandbox/
├── README.md                    # This file
├── docs/                        # All documentation
│   ├── GOLDEN-IMAGE-*.md       # Backup and restore procedures
│   ├── SANDBOX-*.md            # Setup and testing docs
│   └── README.md               # Original baseline documentation
├── scripts/                     # Sandbox-specific scripts
├── entityDefs/                  # Entity definitions (JSON metadata)
├── layouts/                     # Layout definitions
├── clientDefs/                  # Client definitions
├── recordDefs/                  # Record definitions
└── scopes/                      # Scope definitions
```

---

## 🎯 Current State

### Golden Image (Nov 4, 2025)
- **Row size:** 6,525 / 8,126 bytes (80.3%) ✅
- **TEXT fields:** 113 mediumtext
- **Rebuild-proof:** YES ✅
- **Cache:** Disabled for safe testing

### Backups Created
1. **Tar archive:** `/home/permtrak2/snapshots/sandbox-golden-20251103-2101.tar.gz` (174 MB)
2. **Database dump:** `/home/permtrak2/snapshots/sandbox-db-golden-20251103-2101.sql.gz` (34 MB)
3. **GitHub branch:** `golden-nov4-2025` (this repo + espo-dev repo)

---

## 📚 Key Documentation

### Start Here
- **`docs/GOLDEN-IMAGE-CREATED.md`** - Backup inventory & restore procedures
- **`docs/SANDBOX-READY-FOR-TESTING.md`** - What to test and how

### Background
- **`docs/SANDBOX-SETUP-PLAN.md`** - Original setup plan
- **`docs/SANDBOX-CLONE-SUCCESS.md`** - Clone completion summary
- **`docs/GOLDEN-IMAGE-BACKUP-STRATEGY.md`** - Backup strategy details

---

## 🚀 Quick Reference

### Access Sandbox
```bash
ssh permtrak2@permtrak.com
cd /home/permtrak2/sandbox.permtrak.com/EspoCRM
```

### Restore from Golden Image
```bash
# Full restore (tar + database)
ssh permtrak2@permtrak.com "cd /home/permtrak2 && \
    tar -xzf snapshots/sandbox-golden-20251103-2101.tar.gz"

ssh permtrak2@permtrak.com "zcat /home/permtrak2/snapshots/sandbox-db-golden-20251103-2101.sql.gz | \
    mysql -h localhost -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox"

ssh permtrak2@permtrak.com "cd /home/permtrak2/sandbox.permtrak.com/EspoCRM && \
    php clear_cache.php && php rebuild.php"
```

### Deploy Metadata Changes
```bash
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-sandbox"

# Deploy specific entity
scp entityDefs/TESTPERM.json \
    permtrak2@permtrak.com:/home/permtrak2/sandbox.permtrak.com/EspoCRM/custom/Espo/Custom/Resources/metadata/entityDefs/

# Rebuild after changes
ssh permtrak2@permtrak.com "cd /home/permtrak2/sandbox.permtrak.com/EspoCRM && \
    php clear_cache.php && php rebuild.php"
```

### Check Database Status
```bash
ssh permtrak2@permtrak.com "mysql -h localhost -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' \
    permtrak2_sandbox -e 'SELECT 
        SUM(CASE WHEN DATA_TYPE = \"varchar\" THEN CHARACTER_MAXIMUM_LENGTH * 4 
            WHEN DATA_TYPE = \"int\" THEN 4 WHEN DATA_TYPE = \"bigint\" THEN 8 
            WHEN DATA_TYPE = \"tinyint\" THEN 1 WHEN DATA_TYPE = \"double\" THEN 8 
            WHEN DATA_TYPE = \"datetime\" THEN 8 WHEN DATA_TYPE = \"date\" THEN 3 
            ELSE 0 END) as bytes_used,
        8126 as limit_bytes,
        ROUND(SUM(CASE WHEN DATA_TYPE = \"varchar\" THEN CHARACTER_MAXIMUM_LENGTH * 4 
            WHEN DATA_TYPE = \"int\" THEN 4 WHEN DATA_TYPE = \"bigint\" THEN 8 
            WHEN DATA_TYPE = \"tinyint\" THEN 1 WHEN DATA_TYPE = \"double\" THEN 8 
            WHEN DATA_TYPE = \"datetime\" THEN 8 WHEN DATA_TYPE = \"date\" THEN 3 
            ELSE 0 END) / 8126 * 100, 1) as percent_used
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = \"permtrak2_sandbox\" 
        AND TABLE_NAME = \"t_e_s_t_p_e_r_m\" 
        AND DATA_TYPE NOT IN (\"text\", \"mediumtext\", \"longtext\");' 2>&1 | grep -v Warning"
```

---

## 🧪 Testing Workflow

1. **Make change** (Layout Manager, Entity Manager, metadata edit)
2. **Test in UI** (verify records open/save correctly)
3. **Run rebuild** (`php rebuild.php`)
4. **Verify stable** (check row size, test UI again)
5. **If successful:** Document and commit to GitHub
6. **If broken:** Restore from golden image

---

## 📊 Planned Experiments

- [ ] Test Layout Manager field removal (trx field)
- [ ] Test Entity Manager field deletion (parentid field)
- [ ] Test PWD field repositioning
- [ ] Verify cache-disabled workflow
- [ ] Document what works/breaks

---

## 🔗 Related Repositories

- **`k4rlski/espo-sandbox`** - This repo (sandbox metadata)
- **`k4rlski/espo-dev`** - Dev environment metadata and general documentation

---

## ⚠️ Important Notes

- **Cache is DISABLED** - This is intentional for testing
- **This is NOT production** - Experiment freely, golden image exists
- **Commit often** - Document changes as you go
- **Test thoroughly** - Verify after every change

---

**Last Updated:** November 4, 2025
**Golden Image Created:** November 3, 2025 21:01 (Chiang Mai Time)

