# Workspace Organization - Sandbox vs Dev

**Date:** November 4, 2025
**Purpose:** Clarify which files go where and which GitHub repo to use

---

## 📁 Two Separate Repositories

### 1. `espo-dev` Repository
**Local Path:** `/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-dev`
**GitHub:** `k4rlski/espo-dev`
**Purpose:** Development environment (dev.permtrak.com) and general EspoCRM documentation

**What Lives Here:**
- ✅ Dev environment metadata (when ready to deploy)
- ✅ General EspoCRM documentation
  - ESPOCRM-REBUILD-METADATA-SYNC-SOLUTION.md
  - ENTITY-MANAGER-BEST-PRACTICES.md
  - BREAKTHROUGH-SUMMARY-NOV4-2025.md
- ✅ PWD entity documentation and history
- ✅ TESTPERM analysis and fix scripts
- ✅ Session summaries
- ✅ General tools and scripts

**Branches:**
- `main` - Current dev state
- `golden-nov4-2025` - Golden image snapshot

---

### 2. `espo-sandbox` Repository
**Local Path:** `/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-sandbox`
**GitHub:** `k4rlski/espo-sandbox`
**Purpose:** Sandbox environment (sandbox.permtrak.com) for safe experimentation

**What Lives Here:**
- ✅ Sandbox environment metadata (current state on sandbox.permtrak.com)
  - entityDefs/
  - layouts/
  - clientDefs/
  - recordDefs/
  - scopes/
- ✅ Sandbox-specific documentation (in `docs/` subdirectory)
  - SANDBOX-*.md (setup, testing, status)
  - GOLDEN-IMAGE-*.md (backup and restore)
- ✅ Sandbox-specific scripts (in `scripts/` subdirectory)
- ✅ Experiment results and testing notes

**Branches:**
- `main` - Current sandbox state
- `golden-nov4-2025` - Golden image snapshot (Nov 4, 2025, 21:01)

---

## 🎯 Workflow: Where to Work

### When Working on Sandbox
```bash
# Always start here
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-sandbox"

# Edit metadata
vim entityDefs/TESTPERM.json

# Deploy to sandbox
scp entityDefs/TESTPERM.json permtrak2@permtrak.com:/home/permtrak2/sandbox.permtrak.com/EspoCRM/custom/Espo/Custom/Resources/metadata/entityDefs/

# Test, document, commit
vim docs/SANDBOX-TESTING-RESULTS.md
git add -A
git commit -m "Experiment: Tested field removal"
git push origin main
```

### When Working on Dev
```bash
# Work from dev directory
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-dev"

# Edit metadata
vim entityDefs/TESTPERM.json

# Deploy to dev
scp entityDefs/TESTPERM.json permtrak2@permtrak.com:/home/permtrak2/dev.permtrak.com/EspoCRM/custom/Espo/Custom/Resources/metadata/entityDefs/

# Commit
git add -A
git commit -m "Update: Applied successful sandbox experiment to dev"
git push origin main
```

### When Writing General Documentation
```bash
# General EspoCRM knowledge goes to espo-dev
cd "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-dev"
vim ESPOCRM-BEST-PRACTICES.md
```

---

## 🔄 Migration Path: Sandbox → Dev → Prod

```
1. EXPERIMENT on sandbox.permtrak.com
   └─ Work in: espo-sandbox repo
   └─ Test freely, golden image exists
   
2. DOCUMENT successful changes
   └─ Create: docs/SANDBOX-TESTING-RESULTS.md
   └─ Note what worked, what didn't
   
3. APPLY to dev.permtrak.com
   └─ Copy successful changes to: espo-dev repo
   └─ Test on dev environment
   └─ Monitor for 1-2 days
   
4. DEPLOY to prod.permtrak.com (eventually)
   └─ After dev is stable
   └─ With full backups
```

---

## 📊 Current File Organization

### espo-sandbox/ (This Repo)
```
espo-sandbox/
├── README.md                           # Quick reference
├── docs/                               # All documentation
│   ├── GOLDEN-IMAGE-BACKUP-STRATEGY.md # How backups work
│   ├── GOLDEN-IMAGE-CREATED.md        # Backup inventory
│   ├── SANDBOX-SETUP-PLAN.md          # Original setup plan
│   ├── SANDBOX-CLONE-SUCCESS.md       # Clone completion
│   ├── SANDBOX-READY-FOR-TESTING.md   # Testing procedures
│   ├── WORKSPACE-ORGANIZATION.md      # This file
│   └── README.md                       # Baseline documentation
├── scripts/                            # Sandbox tools (empty for now)
├── entityDefs/                         # Entity metadata (62 files)
├── layouts/                            # Layout definitions (22 subdirs)
├── clientDefs/                         # Client definitions (51 files)
├── recordDefs/                         # Record definitions (4 files)
└── scopes/                             # Scope definitions (49 files)
```

### espo-dev/ (Other Repo)
```
espo-dev/
├── README.md
├── ESPOCRM-REBUILD-METADATA-SYNC-SOLUTION.md
├── ENTITY-MANAGER-BEST-PRACTICES.md
├── BREAKTHROUGH-SUMMARY-NOV4-2025.md
├── SESSION-SUMMARY-NOV3-2025.md
├── PWD-*.md (various PWD-related docs)
├── TESTPERM-ANALYSIS.md
├── fix-*.py (Python fix scripts)
├── *.sql (SQL scripts)
├── entityDefs/
│   ├── PWD.json
│   ├── TESTPERM.json
│   └── ... (other entities)
└── ... (layouts, clientDefs, etc.)
```

---

## ✅ Key Takeaways

1. **Two repos, two purposes:**
   - `espo-sandbox` = Sandbox testing environment
   - `espo-dev` = Dev environment + general knowledge

2. **Always work from the right directory:**
   - Sandbox work → espo-sandbox/
   - Dev work → espo-dev/

3. **Sandbox is your safe playground:**
   - Golden image exists
   - Experiment freely
   - Document findings

4. **Dev is your staging area:**
   - Apply successful experiments here
   - Test thoroughly before prod

5. **Documentation belongs where it's relevant:**
   - Sandbox-specific → espo-sandbox/docs/
   - General EspoCRM knowledge → espo-dev/

---

**You're now organized and ready to work from the correct location!** 🎯

