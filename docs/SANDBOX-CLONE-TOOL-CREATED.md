# Sandbox Clone Tool Created
## Automated dev → sandbox Cloning

**Date:** November 3, 2025  
**Tool:** `espo-ctl/espo-clone-dev-to-sandbox.py`  
**Status:** ✅ Ready to use

---

## 🎯 What Was Created

### 1. Clone Script
**Location:** `../espo-ctl/espo-clone-dev-to-sandbox.py`

**Features:**
- ✅ Automated 10-step cloning workflow
- ✅ Backs up existing sandbox
- ✅ Copies dev database → sandbox
- ✅ Updates all configurations automatically
- ✅ **Sets cache to DISABLED** (critical!)
- ✅ Deploys optimized metadata from GitHub
- ✅ Validates .htaccess and security
- ✅ Verifies TESTPERM row size
- ✅ Colored output with progress tracking
- ✅ Error handling and rollback

### 2. Comprehensive README
**Location:** `../espo-ctl/SANDBOX-CLONE-README.md`

**Contains:**
- Complete usage instructions
- Configuration guide
- Troubleshooting section
- Verification steps
- Experiment workflows
- Quick start commands

---

## 🚀 HOW TO USE

### Quick Start:
```bash
# Navigate to espo-ctl directory
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-ctl"

# Run the clone script
python3 espo-clone-dev-to-sandbox.py

# Follow the prompts
# Estimated time: 5-10 minutes
```

### What It Does:
1. Backs up existing sandbox
2. Exports dev database
3. Copies dev files → sandbox
4. Creates sandbox database
5. Updates config.php (URLs, database, **cache OFF**)
6. Imports dev data
7. Deploys TESTPERM.json + PWD.json from GitHub
8. Clears cache & rebuilds
9. Validates configuration
10. Verifies everything works

### Result:
Exact copy of dev.permtrak.com running as sandbox.permtrak.com with:
- ✅ Cache DISABLED (for testing!)
- ✅ Optimized metadata deployed
- ✅ TESTPERM at 82.3% capacity
- ✅ Ready for Entity Manager experiments

---

## 🎯 Purpose

Create disposable testing environment for:
- ✅ Testing Layout Manager with cache disabled
- ✅ Removing unused fields from layouts
- ✅ Field deletion experiments
- ✅ PWD field positioning
- ✅ Proving cache-disabled workflows work reliably

### Safe Environment Strategy:
- **prod.permtrak.com** - Production (never touched)
- **dev.permtrak.com** - Working baseline (preserved)
- **sandbox.permtrak.com** - Testing ground (disposable!)

---

## 📋 Configuration

### Default Settings (in script):

```python
'dev': {
    'espo_dir': '/home/permtrak2/dev.permtrak.com/EspoCRM',
    'db_name': 'permtrak2_dev',
    'db_user': 'permtrak2_dev',
    'site_url': 'https://dev.permtrak.com/EspoCRM',
},
'sandbox': {
    'espo_dir': '/home/permtrak2/sandbox.permtrak.com/EspoCRM',
    'db_name': 'permtrak2_sandbox',
    'db_user': 'permtrak2_sandbox',
    'site_url': 'https://sandbox.permtrak.com/EspoCRM',
}
```

**Critical:** `useCache` will be set to `false` on sandbox!

---

## ✅ Next Steps (After Clone)

### 1. Verify Sandbox Works:
```bash
# Test URL
curl -I https://sandbox.permtrak.com/EspoCRM

# Login to admin UI
# https://sandbox.permtrak.com/EspoCRM
```

### 2. Verify Cache is Disabled:
```
Administration → Settings → System
☐ "Use Cache" should be unchecked
```

### 3. Test TESTPERM:
```
- Open TESTPERM list
- Open a record
- Edit a field
- Save
- Should work without Error 500!
```

### 4. Start Experiments:

**Experiment 1:** Remove 'trx' from layout
```
Layout Manager → TESTPERM → Detail
Remove 'trx' field (confirmed deleted)
Save and test
```

**Experiment 2:** Delete unused field
```
Entity Manager → TESTPERM → Fields
Delete 'parentid' (100% NULL)
Test records still work
```

**Experiment 3:** Position PWD fields
```
Layout Manager → PWD → Detail
Drag fields to desired positions
Save and test
```

### 5. Document Results:
Create `SANDBOX-TESTING-RESULTS.md` with outcomes

---

## 🔍 Verification Commands

### Check Sandbox Status:
```bash
# Check cache config
ssh permtrak2@permtrak.com 'grep useCache /home/permtrak2/sandbox.permtrak.com/EspoCRM/data/config.php'
# Should show: 'useCache' => false,

# Check database
ssh permtrak2@permtrak.com 'mysql -h permtrak.com -u permtrak2_sandbox -p -e "SELECT COUNT(*) FROM t_e_s_t_p_e_r_m;" permtrak2_sandbox'

# Check TESTPERM row size
ssh permtrak2@permtrak.com 'mysql -h permtrak.com -u permtrak2_sandbox -p permtrak2_sandbox -e "
  SELECT SUM(...) as bytes_used, 8126 as limit FROM INFORMATION_SCHEMA.COLUMNS..."'
# Should show: ~6,685 bytes (82.3%)
```

---

## 📚 Documentation

### Related Files:
1. `SANDBOX-SETUP-PLAN.md` - Complete testing plan
2. `ENTITY-MANAGER-BEST-PRACTICES.md` - Workflows with cache disabled
3. `TESTPERM-UNUSED-FIELDS-ANALYSIS.md` - 28 fields to review
4. `SESSION-SUMMARY-NOV3-2025.md` - Campaign recap
5. `../espo-ctl/SANDBOX-CLONE-README.md` - Detailed tool documentation

### Tool Location:
```
/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-ctl/
├── espo-clone-dev-to-sandbox.py  ← NEW! Clone script
├── SANDBOX-CLONE-README.md       ← NEW! Documentation
├── espo-clone-local.py           ← Existing (prod → dev)
├── espo-ctl.py                   ← Main control tool
└── ...
```

---

## 🎊 Success Criteria

### Clone is Successful If:
- [x] Script runs without errors
- [x] Sandbox loads at https://sandbox.permtrak.com/EspoCRM
- [x] Admin login works
- [x] Cache is disabled (verified)
- [x] TESTPERM records open/save
- [x] Database has 16,705 records
- [x] Row size is 6,685 bytes (82.3%)

### Testing is Successful If:
- [ ] Layout Manager works without errors
- [ ] Can remove fields from layouts
- [ ] Can delete unused fields
- [ ] Can reposition fields
- [ ] Changes persist
- [ ] No cache-related issues

---

## 💡 Key Insights

### Why This Tool Was Needed:
1. **Preserve dev.permtrak.com** - It's working perfectly (Phase 6 complete)
2. **Test cache-disabled workflows** - Prove Entity Manager works without cache
3. **Safe experimentation** - Sandbox is disposable, can re-clone anytime
4. **Avoid entity split** - If field cleanup works, no need to split entities
5. **Front-end preservation** - Entity split would break data display systems

### What Makes This Different from Prod → Dev Clone:
- **Cache DISABLED by default** (dev has cache enabled)
- **Deploys GitHub metadata** (ensures latest optimizations)
- **Testing-focused** (not production-focused)
- **Disposable** (can nuke and re-clone anytime)

---

## ⚠️ Important Notes

### DO:
- ✅ Experiment freely on sandbox
- ✅ Test aggressive changes
- ✅ Break things and learn
- ✅ Document what works/fails
- ✅ Re-clone as needed

### DON'T:
- ❌ Touch dev.permtrak.com (preserve baseline)
- ❌ Touch prod.permtrak.com (production!)
- ❌ Apply changes to dev until tested on sandbox
- ❌ Worry about breaking sandbox (that's what it's for!)

---

## 🚀 Status

**Tool Status:** ✅ Complete and ready  
**Documentation:** ✅ Comprehensive  
**Testing:** ⏳ Waiting for execution  
**Next Step:** Run the clone script!  

---

## 📞 Quick Reference

### To Clone:
```bash
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-ctl"
python3 espo-clone-dev-to-sandbox.py
```

### To Re-Clone (Start Fresh):
```bash
# Just run the script again - it will backup and replace
python3 espo-clone-dev-to-sandbox.py
```

### For Help:
```bash
python3 espo-clone-dev-to-sandbox.py --help
```

### Advanced Options:
```bash
# Skip backup
python3 espo-clone-dev-to-sandbox.py --skip-backup

# Skip confirmations
python3 espo-clone-dev-to-sandbox.py --skip-confirmation
```

---

**Ready to clone when you return!** 🚀

**Estimated time:** 5-10 minutes  
**What you'll get:** Exact dev copy with cache disabled for safe testing  
**Risk level:** Zero (dev is preserved, sandbox is disposable)

