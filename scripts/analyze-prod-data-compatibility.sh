#!/bin/bash
################################################################################
# Production Data Compatibility Analysis Script
################################################################################
#
# Purpose: Analyze production database for compatibility with optimized schema
#          BEFORE attempting import to sandbox
#
# Approach: READ-ONLY queries on production database
#           No changes made to production
#
# Output: Detailed report of potential issues:
#         - Data in deleted fields
#         - VARCHAR length violations
#         - ENUM value mismatches
#
# Author: AI Assistant
# Date: 2025-11-04
#
################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Production database credentials (from espo-clone-local.py)
PROD_HOST="permtrak.com"
PROD_USER="permtrak2_prod"
PROD_PASS="xX-6x8-Wcx6y8-9hjJFe44VhA-Xx"
PROD_DB="permtrak2_prod"

# Output file
OUTPUT_FILE="/tmp/prod-data-compatibility-report-$(date +%Y%m%d-%H%M%S).txt"

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║     Production Data Compatibility Analysis                       ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "⚠️  READ-ONLY MODE: No changes will be made to production"
echo ""
echo "Report will be saved to: $OUTPUT_FILE"
echo ""

# Start report
{
echo "═══════════════════════════════════════════════════════════════════"
echo "PRODUCTION DATA COMPATIBILITY ANALYSIS REPORT"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Production Database: $PROD_DB@$PROD_HOST"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "1. DELETED FIELDS DATA CHECK"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

echo "Checking TESTPERM.dateinvoicedlocal..."
ssh permtrak2@$PROD_HOST "mysql -u $PROD_USER -p'$PROD_PASS' $PROD_DB -e \"
  SELECT 
    'dateinvoicedlocal' as field_name,
    COUNT(*) as total_records,
    COUNT(dateinvoicedlocal) as records_with_data,
    COUNT(CASE WHEN dateinvoicedlocal IS NOT NULL AND dateinvoicedlocal != '' THEN 1 END) as non_empty_records
  FROM t_e_s_t_p_e_r_m;
\""

echo ""
echo "Checking TESTPERM.swasmartlink..."
ssh permtrak2@$PROD_HOST "mysql -u $PROD_USER -p'$PROD_PASS' $PROD_DB -e \"
  SELECT 
    'swasmartlink' as field_name,
    COUNT(*) as total_records,
    COUNT(swasmartlink) as records_with_data,
    COUNT(CASE WHEN swasmartlink IS NOT NULL AND swasmartlink != '' THEN 1 END) as non_empty_records
  FROM t_e_s_t_p_e_r_m;
\""

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "2. VARCHAR LENGTH VIOLATIONS CHECK"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

echo "TESTPERM Field Length Analysis:"
echo "--------------------------------"
ssh permtrak2@$PROD_HOST "mysql -u $PROD_USER -p'$PROD_PASS' $PROD_DB -e \"
  SELECT 
    'name' as field_name,
    150 as new_max_length,
    MAX(LENGTH(name)) as current_max_length,
    CASE WHEN MAX(LENGTH(name)) > 150 THEN 'VIOLATION' ELSE 'OK' END as status,
    COUNT(CASE WHEN LENGTH(name) > 150 THEN 1 END) as records_affected
  FROM t_e_s_t_p_e_r_m
  UNION ALL
  SELECT 
    'processor' as field_name,
    100 as new_max_length,
    MAX(LENGTH(processor)) as current_max_length,
    CASE WHEN MAX(LENGTH(processor)) > 100 THEN 'VIOLATION' ELSE 'OK' END as status,
    COUNT(CASE WHEN LENGTH(processor) > 100 THEN 1 END) as records_affected
  FROM t_e_s_t_p_e_r_m
  UNION ALL
  SELECT 
    'entity' as field_name,
    100 as new_max_length,
    MAX(LENGTH(entity)) as current_max_length,
    CASE WHEN MAX(LENGTH(entity)) > 100 THEN 'VIOLATION' ELSE 'OK' END as status,
    COUNT(CASE WHEN LENGTH(entity) > 100 THEN 1 END) as records_affected
  FROM t_e_s_t_p_e_r_m
  UNION ALL
  SELECT 
    'quotereport' as field_name,
    100 as new_max_length,
    MAX(LENGTH(quotereport)) as current_max_length,
    CASE WHEN MAX(LENGTH(quotereport)) > 100 THEN 'VIOLATION' ELSE 'OK' END as status,
    COUNT(CASE WHEN LENGTH(quotereport) > 100 THEN 1 END) as records_affected
  FROM t_e_s_t_p_e_r_m;
\""

echo ""
echo "PWD Field Length Analysis:"
echo "--------------------------"
ssh permtrak2@$PROD_HOST "mysql -u $PROD_USER -p'$PROD_PASS' $PROD_DB -e \"
  SELECT 
    'name' as field_name,
    100 as new_max_length,
    MAX(LENGTH(name)) as current_max_length,
    CASE WHEN MAX(LENGTH(name)) > 100 THEN 'VIOLATION' ELSE 'OK' END as status,
    COUNT(CASE WHEN LENGTH(name) > 100 THEN 1 END) as records_affected
  FROM p_w_d
  UNION ALL
  SELECT 
    'empsoccodes' as field_name,
    30 as new_max_length,
    MAX(LENGTH(empsoccodes)) as current_max_length,
    CASE WHEN MAX(LENGTH(empsoccodes)) > 30 THEN 'VIOLATION' ELSE 'OK' END as status,
    COUNT(CASE WHEN LENGTH(empsoccodes) > 30 THEN 1 END) as records_affected
  FROM p_w_d
  UNION ALL
  SELECT 
    'onettitlecombo' as field_name,
    50 as new_max_length,
    MAX(LENGTH(onettitlecombo)) as current_max_length,
    CASE WHEN MAX(LENGTH(onettitlecombo)) > 50 THEN 'VIOLATION' ELSE 'OK' END as status,
    COUNT(CASE WHEN LENGTH(onettitlecombo) > 50 THEN 1 END) as records_affected
  FROM p_w_d
  UNION ALL
  SELECT 
    'altforeignlanguage' as field_name,
    40 as new_max_length,
    MAX(LENGTH(altforeignlanguage)) as current_max_length,
    CASE WHEN MAX(LENGTH(altforeignlanguage)) > 40 THEN 'VIOLATION' ELSE 'OK' END as status,
    COUNT(CASE WHEN LENGTH(altforeignlanguage) > 40 THEN 1 END) as records_affected
  FROM p_w_d;
\""

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "3. ENUM VALUE VALIDATION"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

echo "Checking PWD.statcase ENUM values..."
ssh permtrak2@$PROD_HOST "mysql -u $PROD_USER -p'$PROD_PASS' $PROD_DB -e \"
  SELECT 
    statcase as value,
    COUNT(*) as count,
    CASE WHEN statcase NOT IN ('', 'Pending', 'Certified', 'Denied', 'Withdrawn') 
      THEN 'INVALID' 
      ELSE 'VALID' 
    END as status
  FROM p_w_d
  WHERE statcase IS NOT NULL
  GROUP BY statcase
  ORDER BY count DESC;
\""

echo ""
echo "Checking PWD.visaclass ENUM values..."
ssh permtrak2@$PROD_HOST "mysql -u $PROD_USER -p'$PROD_PASS' $PROD_DB -e \"
  SELECT 
    visaclass as value,
    COUNT(*) as count,
    CASE WHEN visaclass NOT IN ('', 'H-1B', 'H-1B1', 'E-3', 'PERM', 'Other') 
      THEN 'INVALID' 
      ELSE 'VALID' 
    END as status
  FROM p_w_d
  WHERE visaclass IS NOT NULL
  GROUP BY visaclass
  ORDER BY count DESC;
\""

echo ""
echo "Checking PWD.coveredbyacwia ENUM values..."
ssh permtrak2@$PROD_HOST "mysql -u $PROD_USER -p'$PROD_PASS' $PROD_DB -e \"
  SELECT 
    coveredbyacwia as value,
    COUNT(*) as count,
    CASE WHEN coveredbyacwia NOT IN ('', 'Yes', 'No') 
      THEN 'INVALID' 
      ELSE 'VALID' 
    END as status
  FROM p_w_d
  WHERE coveredbyacwia IS NOT NULL
  GROUP BY coveredbyacwia
  ORDER BY count DESC;
\""

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "4. RECORD COUNTS"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

ssh permtrak2@$PROD_HOST "mysql -u $PROD_USER -p'$PROD_PASS' $PROD_DB -e \"
  SELECT 'PWD' as entity, COUNT(*) as total_records FROM p_w_d
  UNION ALL
  SELECT 'TESTPERM' as entity, COUNT(*) as total_records FROM t_e_s_t_p_e_r_m;
\""

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "5. FIELD EXISTENCE CHECK"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

echo "Checking if deleted fields exist in prod..."
ssh permtrak2@$PROD_HOST "mysql -u $PROD_USER -p'$PROD_PASS' $PROD_DB -e \"
  SHOW COLUMNS FROM t_e_s_t_p_e_r_m LIKE 'dateinvoicedlocal';
\""
ssh permtrak2@$PROD_HOST "mysql -u $PROD_USER -p'$PROD_PASS' $PROD_DB -e \"
  SHOW COLUMNS FROM t_e_s_t_p_e_r_m LIKE 'swasmartlink';
\""

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "ANALYSIS COMPLETE"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "Review the report above for:"
echo "  • RED/VIOLATION items require attention"
echo "  • Data in deleted fields will be lost"
echo "  • VARCHAR violations will cause truncation"
echo "  • INVALID ENUM values need to be added to options"
echo ""

} | tee "$OUTPUT_FILE"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Analysis complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Report saved to: $OUTPUT_FILE"
echo ""
echo "Next Steps:"
echo "1. Review report for VIOLATION or INVALID items"
echo "2. Discuss findings with user"
echo "3. Adjust metadata if needed (increase maxLength, add ENUM values)"
echo "4. If all OK, proceed with sandbox data import test"
echo ""

