# Sandbox Baseline - November 4, 2025

## Environment Details

**URL:** https://sandbox.permtrak.com/EspoCRM  
**PHP Version:** 8.2  
**EspoCRM Version:** 9.2.4  
**Database:** permtrak2_sandbox  
**Records:** 16,705 TESTPERM + 5 PWD

---

## Critical Settings

```php
'useCache' => false,  // ✅ DISABLED for testing!
'siteUrl' => 'https://sandbox.permtrak.com/EspoCRM',
'dbname' => 'permtrak2_sandbox',
```

---

## TESTPERM Status

### Row Size: ✅ UNDER LIMIT
```
Current: 6,685 bytes
Limit: 8,126 bytes
Capacity: 82.3%
Headroom: 1,441 bytes
```

### Field Breakdown:
- **TEXT fields:** 112 (off-row storage)
- **VARCHAR fields:** 62 (in-row)
- **Total fields in entity:** 257
- **Fields in detail layout:** 199
- **Unused fields (in dock):** 28

### Optimization History:
- Phase 1-6 complete on dev
- All optimizations cloned to sandbox
- Zero data loss (all 16,705 records intact)

---

## PWD Status

### Row Size: ✅ Optimized
```
VARCHAR fields optimized with maxLength
14 ENUM fields restored with proper options
Empty string ("") added to ENUM options for validation
```

---

## Testing Goals

### What We're Testing:
1. **Layout Manager** with cache disabled
   - Does field repositioning persist?
   - Do layout changes survive rebuild?

2. **Entity Manager** with cache disabled
   - Can we delete NULL fields without Error 500?
   - Do deletions persist through rebuild?

3. **rebuild vs rebuild --hard**
   - Does rebuild respect our optimizations?
   - Does rebuild --hard revert TEXT conversions?

### Why Cache Disabled:
Previous testing on dev showed `useCache = true` caused:
- ❌ Entity Manager field deletion errors
- ❌ `rebuild --hard` reverted optimizations
- ❌ Layout changes didn't persist
- ❌ Stale metadata issues

**Solution:** Test with cache DISABLED to prove it was the culprit!

---

## Baseline Files Captured

```
baseline/
├── metadata/
│   └── entityDefs/
│       ├── TESTPERM.json  (51,595 bytes, Phase 6 optimized)
│       └── PWD.json        (26,777 bytes, ENUMs restored)
└── layouts/
    └── TESTPERM/
        └── detail.json     (Current layout configuration)
```

---

## Expected Behavior (With Cache Disabled)

### Layout Manager:
- ✅ Changes take effect immediately
- ✅ Changes persist after browser refresh
- ✅ Changes survive "Clear Cache"
- ✅ Changes survive `rebuild.php`

### Entity Manager:
- ✅ Field deletions work without Error 500
- ✅ Deleted fields actually drop from database
- ✅ Changes persist through rebuild

### If These FAIL:
- Something else is wrong (not just cache)
- Need deeper investigation
- May indicate EspoCRM core issue

---

## Next Steps

1. ✅ Baseline captured (this document)
2. ⏳ Test 1: Layout Manager field reposition
3. ⏳ Test 2: Remove unused field from layout
4. ⏳ Test 3: Entity Manager field deletion
5. ⏳ Test 4: rebuild --hard (nuclear option)

---

## Rollback Plan

If anything breaks:
1. Can re-clone sandbox from dev (automated script exists)
2. Can restore metadata from this baseline
3. Can revert database changes via backup
4. Dev environment remains untouched as safety net

**Risk Level:** LOW - Sandbox is disposable!

---

## Success Criteria

### Test 1 Success:
- Field repositioning persists through all checks
- No Error 500
- No unexpected behavior

### Overall Success:
- All Layout Manager operations work reliably
- Entity Manager field deletion works without errors
- Optimizations survive rebuild operations
- Can confidently apply workflows to dev/prod

---

**Baseline Status:** ✅ CAPTURED  
**Ready for Testing:** ✅ YES  
**Date:** 2025-11-04 03:55 UTC

