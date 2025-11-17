# Golden Image: EspoCRM Sandbox
**Version:** 2025-11-17-0119  
**Created:** November 17, 2025 01:19 AM  
**Git Commit:** (to be added)  
**Status:** ✅ Stable - PWD Entity Production-Ready

---

## Overview

This golden image captures the EspoCRM Sandbox (`sandbox.permtrak.com`) with the newly completed **PWD entity** (144 fields) successfully related to **TESTPERM entity** via Many-to-One relationship, with stable Entity Manager operations.

---

## System Details

### EspoCRM Sandbox
- **Domain:** `sandbox.permtrak.com`
- **Server:** `permtrak.com` (permtrak2 user)
- **Path:** `/home/permtrak2/sandbox.permtrak.com/`
- **Database:** `permtrak2_sandbox`
- **Database Host:** `localhost`
- **Database User:** `permtrak2_sandbox`
- **Database Password:** `XTz5*]xF-Zx4=Lx-u`
- **EspoCRM Path:** `/home/permtrak2/sandbox.permtrak.com/EspoCRM/`
- **Version:** EspoCRM (custom build)
- **Caching:** Disabled for Entity Manager testing

### GitHub Repository
- **Repo:** `https://github.com/k4rlski/espo-sandbox`
- **Branch:** `main`
- **Local Path:** `/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-sandbox`

---

## Key Entities in This Golden Image

### PWD Entity (NEW - Production Ready)
- **Entity Name:** `PWD`
- **Database Table:** `p_w_d`
- **Total Fields:** 144
- **Status:** ✅ Stable
- **Relationships:**
  - Many-to-One relationship with TESTPERM (`pwd_id` on PERM case)
  - Successfully tested with Entity Manager
  - `clear-cache`, `rebuild`, `rebuild --hard` all working

**PWD Entity Fields (144 total):**
```
Case Information (13):
- casenumber, datereceived, datedetermination, dateredetermination,
  datecenterdirectorreview, datewithdrawal, statcase, visatype,
  visaclass, datepwdwageexpiration, dateprevailwagedeterm,
  dateupdat, createdat

Employer Information (13):
- employerlegalbusinessname, tradenamedba, employeraddress1,
  employeraddress2, employercity, employerstate, employerpostalcode,
  employercountry, employerprovince, employerphone, employerextension,
  employerfein, naicscode

Employer POC (14):
- employerpocfirstname, employerpocmiddlename, employerpoclastname,
  employerpocjobtitle, employerpocaddress1, employerpocaddress2,
  employerpoccity, employerpocstate, employerpocpostalcode,
  employerpoccountry, employerpocprovince, employerpocphone,
  employerpocphoneext, employerpocemail

Attorney/Agent (15):
- agentattorneyfirstname, agentattorneymiddlename, agentattorneylastname,
  agentattorneyaddress1, agentattorneyaddress2, agentattorneycity,
  agentattorneystate, agentattorneypostalcode, agentattorneycountry,
  agentattorneyprovince, agentattorneyphone, agentattorneyphoneext,
  agentattorneyemailaddress, lawfirmnamebusinessname, lawfirmfein,
  typeofrep

Job & Worksite (11):
- jobtitle, jobduties, supervisorjobtitle, supervise_other_emp,
  travelrequired, traveldetails, primaryworksiteaddress1,
  primaryworksiteaddress2, primaryworksitecity, primaryworksitestate,
  primaryworksitecounty, primaryworksitepostalcode, otherworksitelocation

SOC Codes (11):
- pwdsoccode, pwdsoctitle, onetcode, onettitle, onetcodecombo,
  onettitlecombo, empsoccodes, empsoctitles, suggestedsoccode,
  suggestedsoctitle

Education & Experience (17):
- requirededucationlevel, requiredotherdegree, requirededucationmajor,
  secondeducationmajor, secondeducation, requiredtraining,
  requiredtrainingname, requiredtrainingmonths, requiredexperience,
  requiredexperiencemonths, requiredoccupation, specialskillsrequirements,
  specreqlicensecert, specreqforeignlang, specreqresfellow, specreqother

Alternative Requirements (14):
- alternativerequirements, alteducationlevel, altotherdegree,
  alteducationmajor, alttraining, alttrainingname, alttrainingmonths,
  altexperience, altexperiencemonths, altspecialskills, altlicensecert,
  altforeignlanguage, altresfellowship, altotherreq

Prevailing Wage (9):
- pwdwagerate, pwdunitofpay, pwdoeswagelevel, pwdwagesource,
  wagesourcerequested, pwdsurveyname, surveyname, datesurveypublication,
  wagedetnotes

Alternative PWD (5):
- altpwdwagerate, altpwdunitofpay, altpwdoeswagelevel, altpwdwagesource,
  altpwdsurveyname

Geographic & Compliance (7):
- blsarea, h2bhighestpwd, coveredbyacwia, acwiainsthighereducation,
  acwiaaffiliatednonprofit, acwiaresearchorg, cba, statacwiachanged,
  profsportsleague

Addendums (3):
- addendumsoc, addendumjobduties, addendumeduc

System Fields (8):
- id, name, deleted, description, created_at, modified_at,
  created_by_id, modified_by_id, assigned_user_id
```

### TESTPERM Entity (Enhanced)
- **Entity Name:** `TESTPERM`
- **Database Table:** `t_e_s_t_p_e_r_m`
- **Status:** ✅ Stable
- **New Field:** `pwd_id` (Many-to-One link to PWD)
- **New Relationship:** Many PERM cases can relate to One PWD
- Successfully tested layout changes, field positioning
- `clear-cache`, `rebuild`, `rebuild --hard` all working

**Key TESTPERM Optimizations:**
- VARCHAR fields optimized (reduced from 240 to appropriate sizes)
- Text field row heights adjusted for efficient data entry
- Legacy fields removed (jsbp-related fields)
- ENUM values added to `statewp` for automation workflow

### Other Custom Entities
- **News** - Newspaper advertising
- **Local** - Local newspaper advertising  
- **Radio** - Radio station advertising
- **SWA** - State Workforce Agency
- **Online** - Online job boards
- **CStripetrx** - Stripe transactions (with `perm_id` relationship)
- **CStripeinvoices** - Stripe invoices (with `perm_id` relationship)
- **CStripepaymentlinks** - Stripe payment links (with `permcase` relationship)
- **CCommunications** - Client communications

---

## Recent Changes

### PWD Entity Creation
- Created via PWDx-Espo (PWD Extractor)
- All 144 fields from ETA 9141 form
- Successful Many-to-One relationship to TESTPERM
- Tested with real PWD data from production

### TESTPERM Entity Enhancements
- Added `pwd_id` field (Many-to-One to PWD)
- Added ENUM values to `statewp`: Launch, Provision, Create, Buy, Delete, Revise, Auto-Print, Dbox-Folder
- Optimized VARCHAR field sizes (e.g., `cophone` 240→24)
- Removed legacy fields: `trx`, `adtextjsbp`, `statjsbp`, `actionnotes`, `urljsbp`, `salaryrange`, `autoprintjsbp`, `swasmartlink`, `adtextnews2`
- Text row height automation applied

### Stripe Entities Enhancements
- All three Stripe entities now have relationships to TESTPERM
- Enables transaction/invoice/payment link mapping to PERM cases
- Ready for financial reporting integration

---

## Entity Manager Status

### ✅ Verified Working Operations
- Field addition (VARCHAR, Text, Link, Enum)
- Field deletion (via Entity Manager)
- Field modification (length, type changes)
- Layout changes (field positioning, panel organization)
- Relationship creation (Many-to-One, One-to-Many)
- `clear-cache` - Working ✅
- `rebuild` - Working ✅
- `rebuild --hard` - Working ✅

### ⚠️ Known Limitations
- Entity Manager works correctly when caching is disabled
- Large-scale field deletions should be done carefully
- Always run `clear-cache`, `rebuild`, `rebuild --hard` after Entity Manager changes

---

## Database Schema

### Key Tables
- `p_w_d` - PWD entity (144 fields)
- `t_e_s_t_p_e_r_m` - PERM cases (with `pwd_id`)
- `news` - Newspaper ads
- `local` - Local newspaper ads
- `radio` - Radio ads
- `s_w_a` - SWA postings
- `online` - Online job boards
- `c_stripetrx` - Stripe transactions (with `perm_id`)
- `c_stripeinvoices` - Stripe invoices (with `perm_id`)
- `c_stripepaymentlinks` - Stripe payment links (with `permcase_id`)
- `c_communications` - Communications

### Database Characteristics
- **Size:** ~XXX MB (check actual size)
- **Records:** PWD entities loaded from production
- **Encoding:** UTF-8mb4
- **Collation:** utf8mb4_unicode_ci

---

## Data Sync

### Production to Sandbox Sync
- **Source:** `permtrak2_prod` database on `prod.permtrak.com`
- **Destination:** `permtrak2_sandbox` database on `sandbox.permtrak.com`
- **Method:** Manual MySQL dump/import via script
- **Frequency:** Manual (on-demand)
- **Status:** Working, tested with recent data

**Sync Procedure:**
```bash
# Run from espo-ctl scripts
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-ctl/scripts"
# Use appropriate sync script
```

---

## Metadata Files

### Custom Entity Definitions
Located in: `/home/permtrak2/sandbox.permtrak.com/EspoCRM/custom/Espo/Custom/Resources/metadata/`

Key metadata files:
- `entityDefs/PWD.json` - PWD entity definition (144 fields)
- `entityDefs/TESTPERM.json` - TESTPERM entity definition (with pwd_id)
- `clientDefs/PWD.json` - PWD client configuration
- `clientDefs/TESTPERM.json` - TESTPERM client configuration
- `scopes/PWD.json` - PWD scope configuration
- `scopes/TESTPERM.json` - TESTPERM scope configuration

### Layouts
- PWD layouts (list, detail, filters, search)
- TESTPERM layouts (optimized for workflow)

---

## CFR 656.17 Compliance

### PWD Entity
- Complete ETA 9141 form data capture
- All required fields for Prevailing Wage Determination
- Supports PERM labor certification process
- Data ready for recruitment advertising compliance

### PERM Case Management
- Complete case tracking with PWD relationship
- Media outlet tracking (News, Local, Radio, SWA, Online)
- Financial tracking via Stripe integrations
- Communication logging

---

## Testing Status

### ✅ Verified Working
- PWD entity displays correctly
- TESTPERM-PWD relationship functional
- Entity Manager operations stable
- Layout changes successful
- Field additions/deletions working
- Database rebuild operations working
- No MySQL row size issues
- All custom entities accessible

### ⚠️ Known Issues
- None at this time

---

## Deployment

### How to Create This Golden Image

```bash
# 1. Pull metadata from server
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-sandbox"
# Run metadata pull script

# 2. Create database dump
ssh permtrak2@permtrak.com "mysqldump -h localhost -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox | gzip" > backups/permtrak2_sandbox-2025-11-17-0119.sql.gz

# 3. Create full build backup
ssh permtrak2@permtrak.com "cd /home/permtrak2 && tar czf sandbox-build-2025-11-17-0119.tar.gz sandbox.permtrak.com/EspoCRM/"
scp permtrak2@permtrak.com:/home/permtrak2/sandbox-build-2025-11-17-0119.tar.gz backups/
```

### How to Restore This Golden Image

```bash
# 1. Restore database
gunzip < backups/permtrak2_sandbox-2025-11-17-0119.sql.gz | \
  ssh permtrak2@permtrak.com "mysql -h localhost -u permtrak2_sandbox -p'XTz5*]xF-Zx4=Lx-u' permtrak2_sandbox"

# 2. Restore build (if needed)
scp backups/sandbox-build-2025-11-17-0119.tar.gz permtrak2@permtrak.com:/home/permtrak2/
ssh permtrak2@permtrak.com "cd /home/permtrak2 && tar xzf sandbox-build-2025-11-17-0119.tar.gz"

# 3. Clear cache and rebuild
ssh permtrak2@permtrak.com "cd /home/permtrak2/sandbox.permtrak.com/EspoCRM && php clear_cache.php && php rebuild.php"
```

---

## Related Systems

### Paired WordPress Reports Sandbox
- **Golden Image:** GOLDEN-IMAGE-REPORTS-SB-2025-11-17-0119.md
- **Domain:** `rpx-sb.permtrak.com`
- **Repo:** `https://github.com/k4rlski/reports-sb`
- Includes PWD Extraction View (form-style landscape)
- Includes PWD Report
- All reports connect to this EspoCRM sandbox database

### Development Environment
- **Domain:** `dev.permtrak.com` (EspoCRM)
- **Domain:** `rpx-dev.permtrak.com` (WordPress Reports)
- Can be cloned from this sandbox version

### Staging Environment
- **Domain:** `staging.permtrak.com` (EspoCRM)
- **Domain:** `rpx-st.permtrak.com` (WordPress Reports)
- Can be cloned from this sandbox version

### Production Environment
- **Domain:** `prod.permtrak.com` (EspoCRM)
- **Domain:** `rpx.permtrak.com` (WordPress Reports)
- Data source for sandbox syncs
- **NEVER ALTERED** by automation

---

## PWD Extractor Integration

### PWDx-Espo
- **Repo:** (to be created) `https://github.com/k4rlski/pwdx-espo`
- **Local Path:** `/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/PWD-EXTRACTOR/pwdx-espo`
- Extracts data from ETA 9141 PDFs
- Uploads to PWD entity in this sandbox
- Ready for daemon implementation

---

## Automation Scripts

### EspoCRM Control Scripts
**Location:** `/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-ctl/scripts/`

Key scripts:
- Database sync (prod → sandbox)
- Clear cache automation
- Rebuild automation
- Metadata pull/push
- Environment cloning

---

## Next Steps

### Recommended Actions
1. ✅ Create paired WordPress Reports Sandbox golden image
2. Build PWDx Daemon for automated PWD extraction
3. Build Quote Builder widget in reports-sb
4. Build Quick Quote Report
5. Test environment cloning (sandbox → dev → staging)
6. Setup automated hourly database sync (prod → sandbox)

---

## Tags

`#golden-image` `#espo-sb` `#espocrm` `#pwd-entity` `#144-fields` `#cfr-656-17` `#entity-manager` `#relationships` `#sandbox` `#2025-11-17`

---

**This golden image represents a stable, production-ready EspoCRM Sandbox with complete PWD entity (144 fields), successful TESTPERM-PWD relationship, and verified Entity Manager operations.**

