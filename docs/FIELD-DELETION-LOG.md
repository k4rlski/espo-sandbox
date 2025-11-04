# 🗑️ TESTPERM Field Deletion Log

**Purpose:** Track all field deletions from TESTPERM entity  
**Environment:** sandbox.permtrak.com  
**Method:** 3-step Entity Manager workflow

---

## 📊 Deletion Summary

| Metric | Count |
|--------|-------|
| Total Fields Deleted | 1 |
| Successful Deletions | 1 |
| Failed Deletions | 0 |
| Rollbacks Required | 0 |
| Golden Images Created | 3 (V1, V2, V3) |

---

## 🗂️ Field Deletion History

| # | Date | Field Name | Type | Usage | Bytes Saved | Golden Image | Git Branch | Status |
|---|------|------------|------|-------|-------------|--------------|------------|--------|
| 01 | 2025-11-03 | dateinvoicedlocal | date | 0% NULL | ~4/row | 2025-11-03-2311 | field-deletion-01-dateinvoicedlocal | ✅ Success |

---

## 📝 Detailed Deletion Records

### #01: dateinvoicedlocal

**Deletion Date:** November 3, 2025 @ 23:11  
**Field Type:** DATE  
**Data Present:** 0% (NULL in all records)  
**Reason for Deletion:** Unused invoice date field

**Workflow Steps:**
1. ✅ Entity Manager deletion (01:42:12)
2. ✅ Layout Manager removal (01:50:55)
3. ✅ rebuild --hard (02:02:30)

**Verification:**
- ✅ Field removed from entityDefs/TESTPERM.json
- ✅ Field removed from layouts/TESTPERM/detail.json
- ✅ Database column dropped automatically
- ✅ Records tested: 6904b71c38cebc3d0, 6904b63777cfd7eca
- ✅ No errors, clean UI

**Golden Image:** sandbox-golden-2025-11-03-2311.tar.gz (174 MB)  
**Database Dump:** sandbox-db-golden-2025-11-03-2311.sql.gz (34 MB)  
**Git Branch:** field-deletion-01-dateinvoicedlocal  
**Git Commit:** 5e63de0

**Impact:**
- Bytes per row: ~4 bytes saved
- Total records: ~24,000
- Total space saved: ~96 KB

**Notes:**
- First successful field deletion using Entity Manager
- Validated 3-step workflow
- Discovered rebuild --hard only drops columns when BOTH steps 1 & 2 complete
- Process documented and repeatable

---

## 🎯 Candidate Fields for Future Deletion

| Field Name | Type | Usage % | Priority | Estimated Bytes | Notes |
|------------|------|---------|----------|-----------------|-------|
| adtextnews2 | text | 0% | High | Stored off-row | Ad text field, unused |
| quoterequestnotes | text | 0% | High | Stored off-row | Quote notes, unused |
| [To be identified via forensic analysis] | | | | | |

---

## ✅ Validation Checklist Template

Copy this for each new deletion:

```markdown
### #XX: [fieldname]

**Deletion Date:** YYYY-MM-DD @ HH:MM  
**Field Type:** [type]  
**Data Present:** [%] ([status])  
**Reason for Deletion:** [reason]

**Workflow Steps:**
1. [ ] Entity Manager deletion (timestamp)
2. [ ] Layout Manager removal (timestamp)
3. [ ] rebuild --hard (timestamp)

**Verification:**
- [ ] Field removed from entityDefs/TESTPERM.json
- [ ] Field removed from layouts/TESTPERM/detail.json
- [ ] Database column dropped
- [ ] Records tested: [IDs]
- [ ] No errors, clean UI

**Golden Image:** sandbox-golden-YYYY-MM-DD-HHMM.tar.gz (size)  
**Database Dump:** sandbox-db-golden-YYYY-MM-DD-HHMM.sql.gz (size)  
**Git Branch:** field-deletion-XX-[fieldname]  
**Git Commit:** [hash]

**Impact:**
- Bytes per row: ~X bytes saved
- Total records: ~24,000
- Total space saved: ~X KB

**Notes:**
- [Any issues, observations, or learnings]
```

---

## 📈 Cumulative Impact

### Row Size Reduction

| Golden Image | Row Size % | Row Size Bytes | Fields Deleted | Notes |
|--------------|------------|----------------|----------------|-------|
| V1 (baseline) | 80.3% | 6,528 | 0 | Initial optimized state |
| V2 (layouts) | 80.3% | 6,528 | 0 | Layout changes only |
| V3 (deletion-01) | TBD | TBD | 1 | First field deletion |

**Target:** <75% row size utilization for safety margin

---

## 🎓 Lessons Learned

### From dateinvoicedlocal Deletion

1. **All 3 steps required for complete deletion**
   - Step 1 (Entity Manager) alone leaves "zombie field"
   - Step 2 (Layout Manager) essential for DB cleanup
   - Step 3 (rebuild --hard) auto-drops column

2. **rebuild --hard is intelligent**
   - Only drops columns when safe (not in metadata or layouts)
   - Prevents accidental data loss
   - No manual SQL required

3. **Testing is critical**
   - Test records after each step
   - Verify UI rendering
   - Check for Error 500
   - Confirm database state

4. **Golden images are lifesavers**
   - Enable instant rollback
   - Provide confidence to proceed
   - Essential for enterprise approach

5. **Cache disabled acceptable**
   - Basic CRUD operations work fine
   - Complex operations slower (expected)
   - Will re-enable after structural stabilization

---

## ⚠️ Warnings & Precautions

### Before Deleting Any Field

- [ ] Verify field truly unused (check database data)
- [ ] Verify field not in WordPress reports
- [ ] Check field not referenced in custom code
- [ ] Confirm with stakeholders if uncertain
- [ ] Current golden image exists
- [ ] Cache disabled on sandbox

### During Deletion

- [ ] Follow 3-step workflow exactly
- [ ] Don't skip Layout Manager removal!
- [ ] Test after each step
- [ ] Watch for errors in UI
- [ ] Check EspoCRM logs if issues

### After Deletion

- [ ] Verify database column dropped
- [ ] Test multiple records
- [ ] Create golden image immediately
- [ ] Commit to Git with clear message
- [ ] Update this log
- [ ] Document any issues or learnings

---

## 🚀 Next Steps

1. **Identify next field** - Use forensic analysis to find unused fields
2. **Follow procedure** - Use field-deletion-procedure.md
3. **Test thoroughly** - Verify each deletion works
4. **Create golden image** - After each success
5. **Update this log** - Document everything
6. **Repeat** - Continue until all unused fields removed

---

## 📞 Recovery Procedure

If a deletion causes issues:

```bash
# 1. SSH to server
ssh permtrak2@permtrak.com
cd /home/permtrak2/sandbox.permtrak.com

# 2. Restore EspoCRM from last golden image
rm -rf EspoCRM/
tar -xzf snapshots/sandbox-golden-YYYY-MM-DD-HHMM.tar.gz

# 3. Restore database
mysql -u permtrak2_sandbox -p permtrak2_sandbox < \
  <(gunzip -c snapshots/sandbox-db-golden-YYYY-MM-DD-HHMM.sql.gz)

# 4. Rebuild
cd EspoCRM
php rebuild.php

# 5. Test
# Open records, verify system works

# 6. Git revert
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-sandbox"
git checkout [previous-branch]
```

---

**This log will be updated after each field deletion. Always check the latest entry before proceeding with a new deletion.** ✅

**Last Updated:** November 3, 2025 @ 23:11  
**Last Editor:** AI Assistant

