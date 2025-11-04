# ✅ EXPERIMENT #1: PWD Layout Change - SUCCESS

**Date:** November 4, 2025  
**Environment:** sandbox.permtrak.com  
**Entity:** PWD  
**Type:** Layout Manager - Field Addition  
**Result:** ✅ **COMPLETE SUCCESS**

---

## 🎯 Objective

Test if Layout Manager works correctly with cache disabled, and verify that layout changes persist after rebuild.

---

## 📋 Test Procedure

### Step 1: Make Layout Change
- **Action:** Used Layout Manager to move 2 fields from "Available Fields" to layout
- **URL:** https://sandbox.permtrak.com/EspoCRM/#Admin/layouts/scope=PWD&type=detail
- **Result:** ✅ Saved successfully (no Error 500)

### Step 2: Run Rebuild
- **Action:** Clear cache + rebuild via command line
- **Commands:**
  ```bash
  ssh permtrak2@permtrak.com "cd /home/permtrak2/sandbox.permtrak.com/EspoCRM && \
    php clear_cache.php && php rebuild.php"
  ```
- **Result:** ✅ Completed without errors

### Step 3: Verify Persistence
- **Action:** Checked if layout file exists and was modified
- **File:** `/home/permtrak2/sandbox.permtrak.com/EspoCRM/custom/Espo/Custom/Resources/layouts/PWD/detail.json`
- **Timestamp:** Nov 4, 00:18 (after golden image at 00:01)
- **Result:** ✅ File exists and was updated

### Step 4: UI Verification
- **Action:** Opened PWD record in sandbox UI
- **Checks:**
  - Two new fields visible? ✅ Yes
  - Correct positions? ✅ Yes
  - Record loads without Error 500? ✅ Yes
  - Can edit and save? ✅ Yes
- **Result:** ✅ All checks passed

---

## ✅ Results

| Test Aspect | Expected | Actual | Status |
|-------------|----------|--------|--------|
| Layout save | No Error 500 | Saved successfully | ✅ Pass |
| Rebuild | Completes without error | No errors | ✅ Pass |
| File persistence | detail.json updated | Updated Nov 4 00:18 | ✅ Pass |
| Fields visible | 2 fields in layout | 2 fields visible | ✅ Pass |
| Record functionality | Opens and saves | Works perfectly | ✅ Pass |

---

## 🔍 Key Findings

### What Worked ✅
1. **Layout Manager with cache disabled:** Works perfectly
2. **Rebuild preserves changes:** Layout changes survived rebuild
3. **JSON metadata:** Properly updated by Layout Manager
4. **No validation errors:** Backend accepts layout changes
5. **UI functionality:** Records open, edit, and save normally

### Environment Configuration
- **Cache:** Disabled (`useCache: false`)
- **PHP Version:** 8.2
- **EspoCRM Version:** 9.2.4
- **Database:** permtrak2_sandbox

### Files Modified
- `custom/Espo/Custom/Resources/layouts/PWD/detail.json`

---

## 📊 Comparison: Dev vs Sandbox

| Aspect | Dev (Old Workflow) | Sandbox (New Workflow) |
|--------|-------------------|------------------------|
| Cache | Enabled | Disabled |
| Layout changes | Sometimes reverted | Persisted ✅ |
| Errors | Occasional Error 500 | None ✅ |
| Confidence | Low | High ✅ |

---

## 💡 Lessons Learned

1. **Cache must be disabled for metadata changes**
   - This is critical for Layout Manager and Entity Manager
   - Matches our ENTITY-MANAGER-BEST-PRACTICES.md guidance

2. **Always test rebuild after metadata changes**
   - Ensures changes persist
   - Validates JSON is correct
   - Part of proper EspoCRM workflow

3. **Layout Manager is safe with cache disabled**
   - No need for manual JSON editing for layout changes
   - UI-based changes work correctly

4. **Strict step-by-step testing works**
   - Make change → Rebuild → Verify
   - Professional DevOps approach
   - Catches issues early

---

## 🚀 Next Steps

Based on this success:
1. ✅ Document this experiment (this file)
2. ✅ Commit layout changes to GitHub
3. 🔄 Proceed to Experiment #2: TESTPERM layout change (remove 'trx' field)
4. 🔄 Experiment #3: Entity Manager field deletion
5. 🔄 Compare behavior with cache enabled (eventually on dev)

---

## 🎯 Conclusion

**Experiment #1 was a complete success.** Layout Manager works correctly with cache disabled, changes persist after rebuild, and there are no functional issues.

This validates our sandbox environment setup and gives us confidence to proceed with more complex experiments.

**Status:** ✅ **VALIDATED - SAFE TO PROCEED**

---

**Documented by:** AI Assistant  
**Verified by:** User (manual UI testing)  
**Golden Image:** Available for rollback if needed (not required)

