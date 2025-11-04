# TESTPERM Row Height Optimization Plan

## 📊 Analysis Summary

**Total Text Fields:** 77
- **Fields WITH rows set:** 9
- **Fields WITHOUT rows set:** 68

---

## 🎯 RECOMMENDATION: Change 68 Fields to `rows=1`

### ✅ PRESERVE Multi-Row (11 fields) - Ad Text & Large Content

These fields contain substantial text content and should remain multi-row:

#### **Ad Text Fields (Keep rows=10)**
1. `adtextewp` - EWP Ad Text (currently 10 rows) ✅
2. `adtextjsbp` - JSBP Ad Text (currently 10 rows) ✅
3. `adtextlocal` - Local Ad Text (currently 10 rows) ✅
4. `adtextnews` - News Ad Text (currently 10 rows) ✅
5. `adtextonline` - Online Ad Text (currently 10 rows) ✅
6. `adtextradio` - Radio Ad Text (currently 10 rows) ✅
7. `adtextswa` - SWA Ad Text (currently 10 rows) ✅
8. `jobadtext` - Job Ad Text (currently 10 rows) ✅

#### **Notes/Long Content Fields (Keep rows=8)**
9. `casenotes` - Case Notes (currently 8 rows) ✅

#### **Secondary Ad Text (Add rows=10)**
10. `adtextnews2` - Secondary News Ad Text (currently no rows set) → **ADD rows=10**
11. `description` - Description field (currently no rows set) → **ADD rows=4**

**Total preserved: 11 fields**

---

## 🔧 OPTIMIZE to `rows=1` (66 fields)

These fields contain short text, URLs, codes, names, or addresses that should be single-line:

### 📧 Email Thread Fields (2 fields)
- `dboxemailthreadnews` - Email thread reference
- `dboxemailthreadswa` - Email thread reference

### 🏢 Job Information (13 fields)
- `jobaddress_city` - City name
- `jobaddress_country` - Country name
- `jobaddress_postal_code` - ZIP code
- `jobaddress_state` - State abbreviation
- `jobaddress_street` - Street address
- `jobeducation` - Education requirement (short)
- `jobexperience` - Experience requirement (short)
- `jobhours` - Hours (e.g., "40 hours/week")
- `jobnaics` - NAICS code
- `jobsiteaddress` - Job site address
- `jobsitecity` - Job site city
- `jobsitezip` - Job site ZIP
- `jobtitle` - Job title

### 🏢 Company Information (8 fields)
- `coaddress` - Company address
- `cocity` - Company city
- `cocounty` - Company county
- `coemailcontactstandard` - Email
- `coemailpermads` - Email
- `coemailpermadspass` - Password
- `cofein` - FEIN number
- `conaics` - NAICS code

### 👤 Contact Information (4 fields)
- `contactemail` - Contact email
- `contactname` - Contact name
- `yournamefirst` - First name
- `yournamelast` - Last name

### ⚖️ Attorney Information (3 fields)
- `attyassistant` - Assistant name
- `attyfirm` - Firm name
- `attyname` - Attorney name

### 🔗 URL/Link Fields (23 fields)
- `coemailpermadsloginurl` - Login URL
- `dboxemailthreadcase` - Dropbox link
- `dboxewpend` - Dropbox link
- `dboxewpstart` - Dropbox link
- `dboxjsbpend` - Dropbox link
- `dboxjsbpstart` - Dropbox link
- `dboxlocalts` - Dropbox link
- `dboxnewsts1` - Dropbox link
- `dboxnewsts2` - Dropbox link
- `dboxonlineend` - Dropbox link
- `dboxonlinestart` - Dropbox link
- `dboxradioinvoice` - Dropbox link
- `dboxradioscript` - Dropbox link
- `dboxswaend` - Dropbox link
- `dboxswastart` - Dropbox link
- `stripepaymentlink` - Payment link
- `urlgmailadconfirm` - Gmail URL
- `urljsbp` - JSBP URL
- `urlonline` - Online URL
- `urlqbpaylink` - QuickBooks URL
- `urlswa` - SWA URL
- `urltrxmercury` - Mercury URL
- `urlweb` - Web URL

### 🖨️ Auto Print Fields (4 fields)
- `autoprintewp` - Print link
- `autoprintjsbp` - Print link
- `autoprintonline` - Print link
- `autoprintswa` - Print link

### 📝 Short Text/Code Fields (9 fields)
- `adnumbernews` - Ad number
- `dolbkupcodes` - DOL backup codes
- `domainname` - Domain name
- `parentid` - Parent ID
- `statswaemail` - Email
- `stripeinvoiceid` - Invoice ID
- `swacomment` - Comment (short)
- `swasubacctpass` - Password
- `trxstring` - Transaction string

**Total to optimize: 66 fields**

---

## 📋 Implementation Plan

### Step 1: Create Backup
```bash
cp entityDefs/TESTPERM.json entityDefs/TESTPERM.json.before-bulk-rows
```

### Step 2: Run Automation Script
Modify `scripts/bulk-adjust-text-field-rows.py` to:
- Target `TESTPERM.json` instead of `PWD.json`
- Exclude the 11 fields listed in "PRESERVE" section
- Add `rows=10` to `adtextnews2`
- Add `rows=4` to `description`

### Step 3: Deploy and Test
```bash
# Copy to server
scp entityDefs/TESTPERM.json permtrak2@permtrak.com:/home/permtrak2/sandbox.permtrak.com/EspoCRM/custom/Espo/Custom/Resources/metadata/entityDefs/

# SSH and rebuild
ssh permtrak2@permtrak.com
cd /home/permtrak2/sandbox.permtrak.com/EspoCRM
rm -rf data/cache/*
php rebuild.php
php rebuild.php --hard
```

### Step 4: Verify
- Test TESTPERM record in browser (hard refresh: Ctrl+Shift+R)
- Verify ad text fields still show 10 rows
- Verify other fields show 1 row
- Test edit/save functionality

### Step 5: Commit to GitHub
```bash
git add entityDefs/TESTPERM.json
git commit -m "row height optimization for TESTPERM - 66 fields to rows=1, preserved 11 ad text fields"
git push origin pwd-manual-row-height-edits
```

---

## 🎯 Expected Results

- **UI Improvement:** Cleaner, more compact forms
- **Data Integrity:** No data loss, ad text fields preserved
- **Time Saved:** ~60-90 minutes of manual Entity Manager work
- **Maintainability:** Changes documented and automated

---

## 📊 Before/After Comparison

| Category | Before | After |
|----------|--------|-------|
| Ad Text Fields | 10 rows | 10 rows (preserved) ✅ |
| Case Notes | 8 rows | 8 rows (preserved) ✅ |
| URLs/Links | Default (~4) | 1 row ⬇️ |
| Short Text | Default (~4) | 1 row ⬇️ |
| Addresses | Default (~4) | 1 row ⬇️ |
| Names/Emails | Default (~4) | 1 row ⬇️ |

**Net Result:** 66 fields become single-line, 11 fields remain multi-row for usability.

---

*Generated: 2025-11-04*
*Purpose: Comprehensive row height optimization for TESTPERM entity*

