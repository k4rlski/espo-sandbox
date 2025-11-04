# ✅ GOLDEN IMAGE V2 CREATED - Post-Layout Changes

**Date:** November 4, 2025 ~00:45 (Chiang Mai Time)  
**Version:** v-2025-11-03-2154  
**Status:** 🟢 **COMPLETE & VERIFIED**

---

## 📦 Golden Image V2 Inventory

### Layer 1: Complete System Archive ✅
```
Location: /home/permtrak2/snapshots/sandbox-golden-v-2025-11-03-2154.tar.gz
Size: ~174 MB
Contains: Complete EspoCRM installation (code, config, uploads, custom files)
Excludes: cache/*, logs/* (rebuild automatically)
Restore time: ~2 minutes
```

**Restore command:**
```bash
ssh permtrak2@permtrak.com "cd /home/permtrak2 && \
    tar -xzf snapshots/sandbox-golden-v-2025-11-03-2154.tar.gz"
```

---

### Layer 2: Database Dump ✅
```
Location: /home/permtrak2/snapshots/sandbox-db-golden-v-2025-11-03-2154.sql.gz
Size: ~34 MB (compressed)
Contains: Complete database (schema, data, optimizations, row size fixes)
Restore time: ~5 minutes
```

**Restore command:**
```bash
ssh permtrak2@permtrak.com "zcat /home/permtrak2/snapshots/sandbox-db-golden-v-2025-11-03-2154.sql.gz | \
    mysql -h localhost -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox"
```

---

### Layer 3: GitHub Metadata Branch ✅
```
Repos: 
  - k4rlski/espo-sandbox → branch 'layout-mods-stable'
  
Size: ~2 MB
Contains: All JSON metadata with layout changes
Restore time: Instant (git checkout)
```

**View on GitHub:**
- https://github.com/k4rlski/espo-sandbox/tree/layout-mods-stable

**Restore command:**
```bash
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-sandbox"
git checkout layout-mods-stable
# Copy files to server as needed
```

---

## 🎯 What This Golden V2 Represents

### System State
- **Row size:** 6,525 / 8,126 bytes (80.3%) ✅
- **TEXT fields:** 113 mediumtext fields
- **VARCHAR fields:** 61 (optimized lengths)
- **Status:** Under limit, stable, rebuild-proof

### Layout Changes Included
1. ✅ **PWD Layout:**
   - Added 2 fields: `dateupdat`, `visatype`
   - Tested with rebuild ✅
   - Documented in EXPERIMENT-001-PWD-LAYOUT-SUCCESS.md

2. ✅ **TESTPERM Layout:**
   - Removed unused 'trx' field
   - Removed 'Job Address' compound field (conflict fix)
   - Kept individual address fields (street, city, state, postal)
   - Tested with rebuild + rebuild --hard ✅
   - Documented in EXPERIMENT-002-TESTPERM-LAYOUT-SUCCESS.md

### Critical Fixes Applied
1. ✅ 62 fields converted to TEXT in JSON metadata
2. ✅ `jobaddress` compound field split into individual TEXT fields
3. ✅ All TEXT conversions applied via SQL
4. ✅ JSON and database schema synchronized
5. ✅ Layout files cleaned up to match entity changes
6. ✅ Survived `rebuild` test
7. ✅ Survived `rebuild --hard` test

### Configuration
- **Cache:** Disabled (`useCache: false`)
- **PHP Version:** 8.2
- **EspoCRM Version:** 9.2.4
- **Database:** permtrak2_sandbox

---

## 📊 Comparison: Golden V1 vs V2

| Aspect | V1 (Original) | V2 (Post-Layout) |
|--------|---------------|------------------|
| **Created** | Nov 4, 00:01 | Nov 4, 00:45 |
| **Filename** | 20251103-2101 | v-2025-11-03-2154 |
| **State** | Before layout changes | After layout experiments |
| **PWD layout** | Default | +2 fields |
| **TESTPERM layout** | With trx, compound address | Clean, individual address |
| **Testing** | Basic rebuild | Rebuild + --hard |
| **Use case** | Original baseline | Stable with improvements |

---

## 🔄 Recovery Scenarios

### Scenario 1: Need Original Baseline
**Use Golden V1**
```bash
# Restore files
ssh permtrak2@permtrak.com "cd /home/permtrak2 && \
    tar -xzf snapshots/sandbox-golden-20251103-2101.tar.gz"

# Restore database
ssh permtrak2@permtrak.com "zcat /home/permtrak2/snapshots/sandbox-db-golden-20251103-2101.sql.gz | \
    mysql -h localhost -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox"

# Rebuild
ssh permtrak2@permtrak.com "cd /home/permtrak2/sandbox.permtrak.com/EspoCRM && \
    php clear_cache.php && php rebuild.php"
```
**Result:** Clean slate, before any experiments

---

### Scenario 2: Need Post-Experiment State
**Use Golden V2**
```bash
# Restore files
ssh permtrak2@permtrak.com "cd /home/permtrak2 && \
    tar -xzf snapshots/sandbox-golden-v-2025-11-03-2154.tar.gz"

# Restore database
ssh permtrak2@permtrak.com "zcat /home/permtrak2/snapshots/sandbox-db-golden-v-2025-11-03-2154.sql.gz | \
    mysql -h localhost -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox"

# Rebuild
ssh permtrak2@permtrak.com "cd /home/permtrak2/sandbox.permtrak.com/EspoCRM && \
    php clear_cache.php && php rebuild.php"
```
**Result:** Stable state with successful layout changes

---

### Scenario 3: Just Revert Metadata
**Use Git Branches**
```bash
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-sandbox"

# For original state
git checkout golden-nov4-2025

# For post-experiment state
git checkout layout-mods-stable

# Deploy to server and rebuild
```
**Result:** Quick metadata rollback, data intact

---

## 📋 Verification Checklist

After creating Golden V2:
- [x] Tar archive created and reasonable size (~174 MB)
- [x] Database dump created and compressed (~34 MB)
- [x] Git branch (layout-mods-stable) exists
- [x] Both V1 and V2 files exist on server
- [x] Total disk usage acceptable (~416 MB for both)
- [x] File permissions correct
- [x] Backup documentation complete

---

## 🎯 Success Metrics

**Before today:**
- Row size: 300%+ (completely broken)
- rebuild: Reverted all changes
- Status: Unstable, frustrated

**Golden V1 (00:01):**
- Row size: 80.3% (stable)
- rebuild: Preserves optimizations ✅
- rebuild --hard: Stable ✅
- Status: Rock solid baseline

**Golden V2 (00:45):**
- Row size: 80.3% (still stable)
- rebuild: Preserves optimizations + layout changes ✅
- rebuild --hard: Stable ✅
- Layout improvements: Validated ✅
- Status: Production-ready with improvements

---

## 🚀 Next Steps

With two golden images:
1. ✅ Continue experimenting with confidence
2. ✅ Can rollback to V1 (original) or V2 (improved)
3. 🔄 Test Entity Manager field deletion
4. 🔄 More layout experiments if needed
5. 🔄 Eventually merge layout-mods-stable to main
6. 🔄 Apply successful changes to dev.permtrak.com

---

## ⚠️ Important Notes

- **Disk space:** 416 MB used for both golden images (acceptable)
- **Retention:** Keep both indefinitely - V1=baseline, V2=milestone
- **Naming convention:** Use version tags for future golden images
- **Updates:** Create Golden V3 when significant new changes validated

---

## 📝 Related Documentation

- **Golden V1:** docs/GOLDEN-IMAGE-CREATED.md
- **Experiment #1:** docs/EXPERIMENT-001-PWD-LAYOUT-SUCCESS.md
- **Experiment #2:** docs/EXPERIMENT-002-TESTPERM-LAYOUT-SUCCESS.md
- **Backup Strategy:** docs/GOLDEN-IMAGE-BACKUP-STRATEGY.md

---

**This represents a validated, stable milestone ready for production consideration.**

**Documented by:** AI Assistant  
**Verified by:** Rebuild tests, UI validation  
**Status:** 🟢 **PRODUCTION-READY MILESTONE**

