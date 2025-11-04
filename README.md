# EspoCRM Sandbox Testing Environment

**Purpose:** Safe testing ground for EspoCRM Entity Manager and Layout Manager operations with cache disabled.

**URL:** https://sandbox.permtrak.com/EspoCRM  
**Status:** ✅ Active and ready for testing  
**Database:** permtrak2_sandbox (16,705 TESTPERM records)

---

## 🎯 Why This Repo Exists

After optimizing TESTPERM from 64,165 → 6,685 bytes (89.6% reduction), we discovered that **EspoCRM's caching system** was causing Entity Manager and Layout Manager issues:

- Entity Manager field deletion → Error 500
- `rebuild --hard` → Reverted optimizations  
- Layout changes → Didn't persist

**Solution:** Test all workflows on **sandbox with cache DISABLED** to prove cache was the culprit.

---

## 📁 Repository Structure

```
espo-sandbox/
├── baseline/                    # Initial state (before any tests)
│   ├── metadata/
│   │   └── entityDefs/
│   │       ├── TESTPERM.json   # Phase 6 optimized (6,685 bytes)
│   │       └── PWD.json         # ENUMs restored
│   ├── layouts/
│   │   └── TESTPERM/
│   │       └── detail.json     # Current layout
│   └── docs/
│       └── BASELINE.md          # Baseline documentation
├── experiments/                 # Test results
│   ├── test-001-reposition.md
│   ├── test-002-remove-field.md
│   └── ...
├── scripts/                     # Helper scripts
│   ├── sync-from-sandbox.sh
│   └── deploy-to-sandbox.sh
└── README.md                    # This file
```

---

## 🧪 Testing Plan

### Test 1: Layout Manager - Field Reposition (SAFEST)
**Goal:** Prove layout changes persist with cache disabled  
**Risk:** LOW - No database changes  
**Status:** ⏳ Pending

### Test 2: Layout Manager - Remove Unused Field
**Goal:** Remove 'trx' field from layout (already deleted from entity)  
**Risk:** LOW - Layout only  
**Status:** ⏳ Pending

### Test 3: Entity Manager - Delete NULL Field
**Goal:** Delete 'parentid' field (100% NULL confirmed)  
**Risk:** MEDIUM - Database structure change  
**Status:** ⏳ Pending

### Test 4: rebuild --hard (Nuclear Option)
**Goal:** Verify optimizations survive rebuild --hard  
**Risk:** HIGH - May revert everything  
**Status:** ⏳ Pending

---

## ✅ Success Criteria

### What Success Looks Like:
1. Layout changes persist through browser refresh
2. Layout changes survive "Clear Cache"
3. Layout changes survive `rebuild.php`
4. Entity Manager deletions work without Error 500
5. Field deletions actually drop database columns
6. `rebuild --hard` doesn't revert TEXT conversions

### If These Work:
- ✅ Cache was THE problem
- ✅ Can apply same workflows to dev
- ✅ Eventually apply to prod
- ✅ NO entity split needed!

---

## 🔄 Workflow

### Making Changes:
1. Test on sandbox first (this environment)
2. Document results in `experiments/`
3. Commit changes to this repo
4. If successful, apply to dev
5. Monitor dev for stability
6. Eventually apply to prod

### Rollback:
- Sandbox is disposable - can re-clone anytime
- Dev remains as working baseline
- Prod never touched until fully validated

---

## 📊 Current Status

**Sandbox Environment:**
- Row Size: 6,685 bytes (82.3% capacity) ✅
- Cache: DISABLED ✅
- PHP: 8.2 ✅
- Records: All 16,705 working ✅
- Metadata: Phase 6 optimized ✅

**Testing Status:**
- Baseline: ✅ Captured
- Test 1: ⏳ Ready to run
- Test 2-4: ⏳ Pending

---

## 🚀 Quick Start

### Clone This Repo:
```bash
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION"
git clone https://github.com/k4rlski/espo-sandbox.git
cd espo-sandbox
```

### View Baseline:
```bash
cat baseline/docs/BASELINE.md
```

### Run Test 1:
See `baseline/docs/TEST-001-LAYOUT-REPOSITION.md` (to be created)

---

## 📚 Related Documentation

- **Main Repo:** https://github.com/k4rlski/espo-dev
- **Dev Environment:** dev.permtrak.com (working baseline)
- **Sandbox Setup:** See SANDBOX-CLONE-SUCCESS.md in espo-dev repo
- **Best Practices:** See ENTITY-MANAGER-BEST-PRACTICES.md in espo-dev repo

---

## ⚠️ Important Notes

1. **Sandbox is DISPOSABLE** - Break it, test aggressively, re-clone anytime
2. **Cache is DISABLED** - This is intentional for testing
3. **Don't touch dev/prod** - Until sandbox tests succeed
4. **Document everything** - Each test gets its own markdown file
5. **Commit frequently** - After each test, commit results

---

## 🎯 Ultimate Goal

Prove that with **cache disabled**, EspoCRM's Entity Manager and Layout Manager work reliably for:
- Field repositioning
- Field deletion
- Layout modifications
- Surviving rebuilds

Then apply these validated workflows to dev → prod pipeline.

**No entity split needed!** 🎉

---

**Status:** ✅ Baseline captured, ready for Test 1  
**Date:** November 4, 2025  
**Maintainer:** k4rlski
