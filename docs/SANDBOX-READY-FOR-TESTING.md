# Sandbox Ready for UI Testing

**Date:** November 4, 2025
**URL:** https://sandbox.permtrak.com/EspoCRM
**Status:** ✅ **READY FOR MANUAL TESTING**

---

## 🎯 What We Accomplished

### 1. **Solved the EspoCRM Rebuild Problem**

**The Issue:**
- SQL changes to database were being reverted by `rebuild`
- Row size would jump from 82% back to 105%
- TEXT conversions wouldn't stick

**The Root Cause:**
- EspoCRM's `rebuild` uses **JSON metadata as source of truth**
- We were changing database via SQL but not updating JSON
- `rebuild` would "correct" database back to what JSON said

**The Solution:**
- Updated `TESTPERM.json` with 62 TEXT field definitions
- Converted `jobaddress` from compound address type to individual TEXT fields
- Now JSON matches database, so `rebuild` preserves our optimizations

**The Proof:**
- ✅ Row size: 6,525 / 8,126 bytes (80.3%)
- ✅ Survived `rebuild` test
- ✅ Survived `rebuild --hard` test
- ✅ Stable and rebuild-proof

---

## 📋 Sandbox Current State

### Database
- **Row size:** 80.3% (STABLE)
- **TEXT fields:** 112
- **VARCHAR fields:** 62

### Configuration
- **Cache:** DISABLED (`useCache: false`)
- **PHP Version:** 8.2
- **EspoCRM:** 9.2.4
- **Database:** permtrak2_sandbox

### Data
- Full copy of `dev.permtrak.com` data
- All records intact
- All optimizations applied

---

## 🧪 Ready for Manual Testing

### Recommended Test Sequence

#### Test 1: Verify TESTPERM Records Work
1. Login to https://sandbox.permtrak.com/EspoCRM
2. Navigate to TESTPERM entity
3. Open several existing records
4. Verify they load without Error 500
5. Try editing and saving a record
6. Confirm data saves correctly

**Expected Result:** Records open and save normally

---

#### Test 2: Layout Manager - Remove 'trx' Field
1. Go to Administration → Layout Manager
2. Select TESTPERM → Detail
3. Find 'trx' field in right panel (unused fields dock)
4. Remove it from layout
5. Save
6. Open a TESTPERM record
7. Verify 'trx' is no longer visible

**Expected Result:** Layout changes persist without Error 500 or rebuild reverting them

---

#### Test 3: Entity Manager - Field Deletion
**Target:** Delete `parentid` field (100% NULL, not used)

1. Go to Administration → Entity Manager
2. Select TESTPERM
3. Go to Fields tab
4. Find `parentid` field
5. Click Remove
6. Confirm deletion
7. Wait for rebuild to complete
8. Test opening TESTPERM records

**Expected Result:** Field deletion works without errors, rebuild completes successfully

---

#### Test 4: PWD Entity - Layout Manager Test
1. Go to Administration → Layout Manager
2. Select PWD → Detail
3. Try repositioning some fields
4. Save
5. Open a PWD record
6. Verify layout changes applied correctly

**Expected Result:** PWD layout changes work correctly

---

### ⚠️  Known Changes from Dev

**`jobaddress` field is now split:**
- Was: Single address widget (street, city, state, zip in one block)
- Now: 4 separate text fields
  - `jobaddress_street`
  - `jobaddress_city`
  - `jobaddress_state`
  - `jobaddress_postal_code`

**Why:** The compound `address` type hardcodes components as VARCHAR. We had to split it to make them TEXT and rebuild-proof.

**Trade-off:** Lost fancy address widget, but gained database stability.

---

## 📊 Monitoring Checklist

After each test, verify:
- [ ] No Error 500 messages
- [ ] Changes persist after page refresh
- [ ] `data/logs/espo-*.log` has no critical errors
- [ ] Row size stays ~80% (check with SQL query)
- [ ] Run `rebuild.php` after Entity Manager changes and verify it completes successfully

---

## 🚀 Next Steps

### If Testing Goes Well:
1. Document test results in `SANDBOX-TESTING-RESULTS.md`
2. Create migration plan to apply same fixes to `dev.permtrak.com`
3. Monitor sandbox for 1-2 days to ensure stability
4. Apply to dev
5. Eventually migrate to prod

### If Issues Arise:
1. Document the specific error
2. Check `data/logs/espo-*.log` for details
3. Verify cache is disabled (`Administration → Settings → Cache`)
4. Check if `rebuild` needs to be run
5. Don't panic - we have full backups of dev and can restore

---

## 📁 Important Files

**On Server:**
- `/home/permtrak2/sandbox.permtrak.com/EspoCRM/custom/Espo/Custom/Resources/metadata/entityDefs/TESTPERM.json`
- `/home/permtrak2/sandbox.permtrak.com/EspoCRM/data/config.php`
- `/home/permtrak2/sandbox.permtrak.com/EspoCRM/data/logs/espo-*.log`

**In Git Repos:**
- `k4rlski/espo-dev` - Main dev metadata
- `k4rlski/espo-sandbox` - Sandbox metadata

**Documentation:**
- `ESPOCRM-REBUILD-METADATA-SYNC-SOLUTION.md` - Full technical explanation
- `SANDBOX-SETUP-PLAN.md` - Original setup plan
- `SANDBOX-CLONE-SUCCESS.md` - Clone completion summary

---

## 🎯 Success Criteria

- [x] Sandbox cloned from dev successfully
- [x] Database optimized to 80.3% row size
- [x] TEXT conversions are rebuild-proof
- [x] Cache disabled for testing
- [ ] **Manual UI testing completed** ← YOU ARE HERE
- [ ] Layout Manager works correctly
- [ ] Entity Manager field deletion works
- [ ] No Error 500 on record open/save
- [ ] Stable for 24-48 hours

---

**You're now ready to test the UI!** If you encounter any issues, we have complete documentation and backups to fall back on.

