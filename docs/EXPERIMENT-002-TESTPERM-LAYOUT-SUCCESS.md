# ✅ EXPERIMENT #2: TESTPERM Layout Cleanup - SUCCESS

**Date:** November 4, 2025  
**Environment:** sandbox.permtrak.com  
**Entity:** TESTPERM  
**Type:** Layout Manager - Field Removal & Address Cleanup  
**Result:** ✅ **COMPLETE SUCCESS**

---

## 🎯 Objective

Test Layout Manager field removal and cleanup address field conflict from earlier TEXT conversion.

---

## 📋 Test Procedure

### Step 1: Identify Issues
- **Issue 1:** Remove unused 'trx' field from layout
- **Issue 2:** Address field conflict error
  - Error: "Fields can't be on the layout together: Job Address Street, Job Address"
  - Root cause: Layout had BOTH compound field and individual fields
  - This was a leftover from our TEXT conversion of jobaddress today

### Step 2: Make Layout Changes
- **Action:** Used Layout Manager to remove fields
- **URL:** https://sandbox.permtrak.com/EspoCRM/#Admin/layouts/scope=TESTPERM&type=detail
- **Removed:**
  1. 'trx' field (unused, identified in earlier analysis)
  2. 'Job Address' compound field (causing conflict)
- **Kept:** Individual address fields (jobaddress_street, jobaddress_city, jobaddress_state, jobaddress_postal_code)
- **Result:** ✅ Saved successfully (no Error 500)

### Step 3: Run Rebuild Tests
- **Action:** Full rebuild sequence via command line
- **Commands:**
  ```bash
  # Clear cache
  ssh permtrak2@permtrak.com "cd /home/permtrak2/sandbox.permtrak.com/EspoCRM && php clear_cache.php"
  
  # Rebuild
  ssh permtrak2@permtrak.com "cd /home/permtrak2/sandbox.permtrak.com/EspoCRM && php rebuild.php"
  
  # Rebuild --hard (aggressive test)
  ssh permtrak2@permtrak.com "cd /home/permtrak2/sandbox.permtrak.com/EspoCRM && php rebuild.php --hard"
  ```
- **Result:** ✅ All completed without errors

### Step 4: Verify Files Updated
- **File:** `/home/permtrak2/sandbox.permtrak.com/EspoCRM/custom/Espo/Custom/Resources/layouts/TESTPERM/detail.json`
- **Timestamp:** Nov 4, 00:34 (updated after changes)
- **Result:** ✅ File exists and was modified

### Step 5: UI Verification
- **Action:** Opened TESTPERM record in sandbox UI
- **URL:** https://sandbox.permtrak.com/EspoCRM/#TESTPERM/view/6905159b12ef6b964
- **Checks:**
  - 'trx' field removed? ✅ Yes - no longer in layout
  - 'Job Address' compound removed? ✅ Yes - no longer in layout
  - Individual address fields present? ✅ Yes - Street, City, State, Postal all visible
  - Record loads without Error 500? ✅ Yes
  - Can edit and save? ✅ Yes
- **Result:** ✅ All checks passed

---

## ✅ Results

| Test Aspect | Expected | Actual | Status |
|-------------|----------|--------|--------|
| Layout save | No Error 500 | Saved successfully | ✅ Pass |
| Address conflict | Resolved | No error after removing compound | ✅ Pass |
| Rebuild | Completes without error | No errors | ✅ Pass |
| Rebuild --hard | Survives aggressive test | Passed | ✅ Pass |
| File persistence | detail.json updated | Updated Nov 4 00:34 | ✅ Pass |
| Fields removed | trx + Job Address gone | Both removed | ✅ Pass |
| Address components | Individual fields remain | All present | ✅ Pass |
| Record functionality | Opens and saves | Works perfectly | ✅ Pass |

---

## 🔍 Key Findings

### What Worked ✅
1. **Layout Manager field removal:** Works correctly with cache disabled
2. **Multiple field removal:** Can remove multiple fields in one save
3. **Address field cleanup:** Resolved conflict from TEXT conversion
4. **Rebuild stability:** Changes survived both rebuild and rebuild --hard
5. **UI functionality:** No errors, records work normally

### Important Discovery 💡
**Address Field Conflict:**
- When we converted `jobaddress` from compound → individual TEXT fields earlier today, we updated the entityDefs but not the layout
- Layout Manager caught the conflict: can't have both compound and individual fields
- This was actually a GOOD catch by EspoCRM validation
- Solution: Remove compound field, keep individual fields

### Environment Configuration
- **Cache:** Disabled (`useCache: false`)
- **PHP Version:** 8.2
- **EspoCRM Version:** 9.2.4
- **Database:** permtrak2_sandbox

### Files Modified
- `custom/Espo/Custom/Resources/layouts/TESTPERM/detail.json`

---

## 📊 Comparison: Experiment #1 vs #2

| Aspect | Exp #1: PWD | Exp #2: TESTPERM |
|--------|-------------|------------------|
| Operation | Add fields | Remove fields |
| Complexity | Simple | Medium (address conflict) |
| Rebuild test | ✅ Pass | ✅ Pass |
| --hard test | Not tested | ✅ Pass |
| Issues found | None | Address field conflict |
| Result | ✅ Success | ✅ Success |

---

## 💡 Lessons Learned

1. **Compound field conversions require layout cleanup**
   - When converting compound fields (address, personName, etc.) to individual fields
   - Must also update layouts to remove compound field reference
   - Layout Manager validation will catch conflicts (good!)

2. **Layout Manager validates field compatibility**
   - Can't have compound field and its components on same layout
   - Error messages are helpful and clear
   - This is a safety feature, not a bug

3. **Multiple changes in one save works**
   - Can remove multiple fields in single Layout Manager session
   - All changes persist after rebuild

4. **rebuild --hard is safe for layout changes**
   - Most aggressive rebuild test passed
   - Layout changes are stable

5. **Strict testing workflow pays off**
   - Make change → Rebuild → Rebuild --hard → Verify
   - Catches issues early
   - Builds confidence in stability

---

## 🚀 Next Steps

Based on two successful experiments:
1. ✅ Document both experiments (this file + EXPERIMENT-001)
2. ✅ Create branch: `layout-mods-stable`
3. ✅ Commit both layout changes to branch
4. 🔄 Consider: More layout tests or move to Entity Manager tests
5. 🔄 Eventually: Merge to main and apply to dev

---

## 🎯 Conclusion

**Experiment #2 was a complete success** with the bonus of discovering and fixing an address field conflict from our earlier TEXT conversion work.

This validates:
- Layout Manager field removal works correctly
- Rebuild --hard doesn't break layout changes
- Address field conversion cleanup is now complete
- System is stable and ready for more experiments

**Status:** ✅ **VALIDATED - SAFE TO PROCEED**

---

## 📝 Related Experiments

- **Experiment #1:** PWD Layout Change (field addition) ✅ Success
- **Experiment #2:** TESTPERM Layout Cleanup (field removal) ✅ Success
- **Next:** Entity Manager field deletion tests

---

**Documented by:** AI Assistant  
**Verified by:** User (manual UI testing)  
**Golden Image:** Available for rollback if needed (not required)  
**Branch:** layout-mods-stable

