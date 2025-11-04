# Production Data Import Strategy

**Date:** 2025-11-04  
**Goal:** Test production data compatibility with optimized sandbox schema  
**Risk Level:** MEDIUM - Schema changes may cause import issues  
**Approach:** Test in sandbox first, then deploy to staging

---

## 🎯 Objective

Verify that production data can be successfully imported into the optimized schema without:
- Data truncation
- Field mismatch errors
- Type conversion issues
- Data integrity violations

---

## 📊 Schema Changes Summary

### Fields Deleted (2 total)
1. **TESTPERM.dateinvoicedlocal** - Deleted via Entity Manager
2. **TESTPERM.swasmartlink** - Deleted via Entity Manager

**Impact:** Prod may have data in these fields that will be lost on import.

### Fields Converted to TEXT (62 in TESTPERM)
- All `url*` fields (8)
- All `dbox*` fields (16)
- All `autoprint*` fields (4)
- Job address components (5)
- Company info fields (8)
- Contact fields (4)
- Attorney fields (3)
- Misc fields (14)

**Impact:** LOW - TEXT accepts all VARCHAR data

### VARCHAR Length Reductions (15 in TESTPERM + 4 in PWD)

**TESTPERM:**
- `name`: ? → 150
- `processor`: ? → 100
- `entity`: ? → 100
- `quotereport`: ? → 100
- Others...

**PWD:**
- `name`: 255 → 100
- `empsoccodes`: 60 → 30
- `onettitlecombo`: 60 → 50
- `altforeignlanguage`: 60 → 40

**Impact:** MEDIUM - Risk of truncation if prod data exceeds new limits

### ENUM Fields Added (14 in PWD)
- `statcase`, `visaclass`, `typeofrep`, etc.

**Impact:** LOW - Existing data should match ENUM options

### Row Height Changes (119 fields)
**Impact:** NONE - Display only, no database schema change

---

## 🧪 Testing Strategy

### Phase 1: Pre-Import Analysis (READ-ONLY on Prod)

**Purpose:** Identify potential issues BEFORE attempting import

**Script:** `scripts/analyze-prod-data-compatibility.sh`

**Checks:**
1. **Deleted Fields Data Check**
   ```sql
   SELECT COUNT(*) FROM t_e_s_t_p_e_r_m WHERE dateinvoicedlocal IS NOT NULL;
   SELECT COUNT(*) FROM t_e_s_t_p_e_r_m WHERE swasmartlink IS NOT NULL;
   ```

2. **VARCHAR Length Violations**
   ```sql
   -- Check if any data exceeds new maxLength
   SELECT 
     MAX(LENGTH(name)) as max_name_length,
     MAX(LENGTH(processor)) as max_processor_length,
     -- etc...
   FROM t_e_s_t_p_e_r_m;
   ```

3. **ENUM Value Mismatches**
   ```sql
   -- Check for values not in ENUM options
   SELECT DISTINCT statcase FROM p_w_d WHERE statcase NOT IN ('', 'Pending', 'Certified', 'Denied', 'Withdrawn');
   ```

4. **Field Existence Check**
   ```sql
   -- Verify deleted fields exist in prod
   SHOW COLUMNS FROM t_e_s_t_p_e_r_m LIKE 'dateinvoicedlocal';
   SHOW COLUMNS FROM t_e_s_t_p_e_r_m LIKE 'swasmartlink';
   ```

**Output:** Report showing:
- Number of records with data in deleted fields
- Maximum field lengths vs new limits
- Invalid ENUM values (if any)
- Estimated data loss/truncation

---

### Phase 2: Sandbox Import Test

**Purpose:** Actually import prod data and observe what breaks

**Prerequisites:**
- ✅ Golden Image V6 documented and backed up
- ✅ Pre-import analysis completed
- ✅ Restore procedure tested and ready

**Steps:**

1. **Backup Current Sandbox**
   ```bash
   # Already done in Golden Image V6 ✅
   # Files:
   #   - espocrm-sandbox-golden-v-2025-11-04-0109.tar.gz
   #   - permtrak2_sandbox-golden-v-2025-11-04-0109.sql
   ```

2. **Export Production Database (READ-ONLY)**
   ```bash
   ssh permtrak2@permtrak.com
   cd /home/permtrak2/prod.permtrak.com
   
   # Export with error logging
   mysqldump -u [prod_user] -p'[prod_pass]' [prod_db] \
     --single-transaction \
     --routines \
     --triggers \
     2> mysqldump-errors.log \
     | gzip > /tmp/prod-export-$(date +%Y%m%d-%H%M%S).sql.gz
   
   # Copy to local for import
   scp permtrak2@permtrak.com:/tmp/prod-export-*.sql.gz \
     /home/falken/DEVOPS\ Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-sandbox/
   ```

3. **Drop and Recreate Sandbox Database**
   ```bash
   ssh permtrak2@permtrak.com
   mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' -e "DROP DATABASE permtrak2_sandbox;"
   mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' -e "CREATE DATABASE permtrak2_sandbox CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
   ```

4. **Import Production Data**
   ```bash
   # Import with error logging
   gunzip < /tmp/prod-export-*.sql.gz | \
     mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox \
     2> import-errors.log
   
   # Check for errors
   cat import-errors.log
   ```

5. **Run Post-Import Analysis**
   ```bash
   # Check row counts
   mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox << 'EOF'
   SELECT 'PWD' as entity, COUNT(*) as count FROM p_w_d;
   SELECT 'TESTPERM' as entity, COUNT(*) as count FROM t_e_s_t_p_e_r_m;
   EOF
   
   # Check for truncation warnings
   mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox -e "SHOW WARNINGS;"
   ```

6. **Deploy Optimized Metadata**
   ```bash
   # Copy from GitHub repo
   cd /home/falken/DEVOPS\ Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-sandbox
   
   scp entityDefs/PWD.json \
     permtrak2@permtrak.com:/home/permtrak2/sandbox.permtrak.com/EspoCRM/custom/Espo/Custom/Resources/metadata/entityDefs/
   
   scp entityDefs/TESTPERM.json \
     permtrak2@permtrak.com:/home/permtrak2/sandbox.permtrak.com/EspoCRM/custom/Espo/Custom/Resources/metadata/entityDefs/
   ```

7. **Rebuild and Test**
   ```bash
   ssh permtrak2@permtrak.com
   cd /home/permtrak2/sandbox.permtrak.com/EspoCRM
   
   # Clear cache
   rm -rf data/cache/*
   
   # Rebuild
   php rebuild.php 2>&1 | tee rebuild.log
   
   # Rebuild --hard (will drop deleted columns, adjust lengths)
   php rebuild.php --hard 2>&1 | tee rebuild-hard.log
   
   # Check for errors
   grep -i error rebuild-hard.log
   ```

8. **UI Testing**
   ```bash
   # Test URLs (hard refresh: Ctrl+Shift+R)
   https://sandbox.permtrak.com/EspoCRM/#PWD
   https://sandbox.permtrak.com/EspoCRM/#TESTPERM
   
   # Try to open/edit records
   # Verify no errors
   # Check for truncated data
   ```

9. **Document Findings**
   - Record any truncation
   - Note field mismatch errors
   - Document workarounds needed
   - Update this document with results

---

### Phase 3: Fix Issues (If Any)

**If truncation detected:**
1. Identify which fields are truncated
2. Review business impact with user
3. Options:
   - Increase maxLength in metadata
   - Convert field to TEXT
   - Accept truncation (if rare/unused data)

**If deleted fields have important data:**
1. Review with user
2. Options:
   - Keep fields as hidden (don't delete)
   - Export data before import
   - Accept data loss (if obsolete)

**If ENUM mismatches:**
1. Add missing values to ENUM options
2. Update metadata
3. Re-deploy

---

### Phase 4: Re-Test After Fixes

- Restore Golden Image V6
- Apply fixes to metadata
- Re-run import test
- Verify all issues resolved
- Update Golden Image if needed

---

### Phase 5: Clone to Staging

**Only proceed after sandbox import test is 100% successful**

1. Clone sandbox to staging (new script)
2. Update staging config:
   - Set `useCache: true` (ENABLE caching)
   - Update `siteUrl` to staging URL
   - Update database credentials
3. Import prod data to staging
4. Run full test suite
5. WordPress integration testing
6. User acceptance testing

---

## 📋 Success Criteria

- [ ] Pre-import analysis shows no showstopper issues
- [ ] Prod database exports successfully (no errors)
- [ ] Import to sandbox completes (no SQL errors)
- [ ] Rebuild --hard succeeds (no errors)
- [ ] PWD records open/save correctly
- [ ] TESTPERM records open/save correctly
- [ ] No visible data truncation
- [ ] Row counts match prod
- [ ] All deleted fields dropped successfully
- [ ] TEXT conversions intact
- [ ] Row height optimizations display correctly

---

## 🚨 Rollback Plan

**If import fails:**
1. Restore Golden Image V6 to sandbox
   ```bash
   cd /home/permtrak2/sandbox.permtrak.com
   rm -rf EspoCRM/
   tar -xzf snapshots/espocrm-sandbox-golden-v-2025-11-04-0109.tar.gz
   
   mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' -e "DROP DATABASE permtrak2_sandbox;"
   mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' -e "CREATE DATABASE permtrak2_sandbox CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
   mysql -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox < snapshots/permtrak2_sandbox-golden-v-2025-11-04-0109.sql
   ```

2. Document issues
3. Fix in GitHub repo
4. Re-test

---

## 📊 Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Data truncation | MEDIUM | HIGH | Pre-import analysis, increase maxLength |
| Deleted field data loss | LOW | MEDIUM | Pre-import check, user review |
| Import SQL errors | LOW | HIGH | Test in sandbox first |
| ENUM mismatches | LOW | LOW | Add missing values to options |
| TEXT conversion issues | VERY LOW | LOW | TEXT accepts all VARCHAR data |
| Rebuild failure | LOW | HIGH | Golden Image V6 available |

---

## 🎯 Next Steps

1. **Decision Point:** Test in sandbox first? ⭐ RECOMMENDED
   - YES → Proceed with Phase 1 (Pre-Import Analysis)
   - NO → Skip to staging clone (RISKY)

2. **Get Prod Database Credentials**
   - Need read-only access for mysqldump
   - Confirm no changes will be made to prod

3. **Review Pre-Import Analysis Results**
   - User decision on truncation/deletions
   - Adjust metadata if needed

4. **Execute Sandbox Import Test**
   - Document everything
   - Take screenshots of any errors

5. **Iterate Until Success**
   - Fix, test, repeat

6. **Proceed to Staging**
   - Only after 100% success in sandbox

---

*Strategy Document Created: 2025-11-04*  
*Status: Ready for Phase 1 (Pre-Import Analysis)*

