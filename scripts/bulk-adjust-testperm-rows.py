#!/usr/bin/env python3
"""
Bulk Text Field Row Height Adjuster for TESTPERM
================================================

This script adjusts the 'rows' parameter for text/textarea fields in TESTPERM.json

Strategy:
- Set 66 fields to rows=1 (URLs, addresses, names, codes, etc.)
- Preserve 8 ad text fields at rows=10
- Preserve casenotes at rows=8
- Add rows=10 to adtextnews2
- Add rows=4 to description

Author: AI Assistant
Date: 2025-11-04
"""

import json
import sys
import os

def adjust_testperm_rows(json_file_path, output_file_path):
    """
    Adjust row heights for TESTPERM text fields
    
    Args:
        json_file_path: Path to TESTPERM.json
        output_file_path: Path to save the modified JSON
    """
    
    # Fields to PRESERVE or ADD specific rows values
    preserve_fields = {
        # Ad Text Fields (Keep rows=10)
        'adtextewp': 10,
        'adtextjsbp': 10,
        'adtextlocal': 10,
        'adtextnews': 10,
        'adtextonline': 10,
        'adtextradio': 10,
        'adtextswa': 10,
        'jobadtext': 10,
        
        # Secondary ad text (ADD rows=10)
        'adtextnews2': 10,
        
        # Description field (ADD rows=4)
        'description': 4,
        
        # Case notes (Keep rows=8)
        'casenotes': 8,
    }
    
    print(f"\n{'='*80}")
    print("📝 TESTPERM Row Height Adjuster")
    print(f"{'='*80}\n")
    print(f"Reading: {json_file_path}")
    
    # Read the JSON file
    with open(json_file_path, 'r') as f:
        data = json.load(f)
    
    # Track changes
    preserved_count = 0
    optimized_count = 0
    already_optimized = 0
    skipped_count = 0
    
    print(f"\n{'='*80}")
    print("🔧 Processing Text Fields")
    print(f"{'='*80}\n")
    
    # Iterate through all fields
    for field_name, field_def in data['fields'].items():
        field_type = field_def.get('type')
        
        # Only process text/textarea fields
        if field_type not in ['text', 'textarea']:
            continue
        
        current_rows = field_def.get('rows', 'NOT SET')
        
        # Check if this field should be preserved with specific rows
        if field_name in preserve_fields:
            target_rows = preserve_fields[field_name]
            if current_rows != target_rows:
                field_def['rows'] = target_rows
                print(f"  ✅ PRESERVED: {field_name:<35} {current_rows} → {target_rows} rows")
                preserved_count += 1
            else:
                print(f"  ✓  ALREADY OK: {field_name:<35} {current_rows} rows (preserved)")
                preserved_count += 1
        
        # Otherwise, set to rows=1 for optimization
        else:
            if current_rows == 1:
                already_optimized += 1
            else:
                field_def['rows'] = 1
                print(f"  🔧 OPTIMIZED: {field_name:<35} {current_rows} → 1 row")
                optimized_count += 1
    
    # Write the modified JSON
    with open(output_file_path, 'w') as f:
        json.dump(data, f, indent=4)
    
    print(f"\n{'='*80}")
    print("📊 SUMMARY")
    print(f"{'='*80}")
    print(f"  ✅ Preserved fields (multi-row):  {preserved_count}")
    print(f"  🔧 Optimized to rows=1:           {optimized_count}")
    print(f"  ✓  Already optimized:             {already_optimized}")
    print(f"  📝 Total text fields processed:   {preserved_count + optimized_count + already_optimized}")
    print(f"\n{'='*80}")
    print("✅ CHANGES COMPLETE")
    print(f"{'='*80}")
    print(f"Output written to: {output_file_path}\n")
    
    return {
        'preserved': preserved_count,
        'optimized': optimized_count,
        'already_optimized': already_optimized,
        'total': preserved_count + optimized_count + already_optimized
    }


if __name__ == "__main__":
    # Define paths
    current_dir = "/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-sandbox"
    json_path = f"{current_dir}/entityDefs/TESTPERM.json"
    backup_path = f"{current_dir}/entityDefs/TESTPERM.json.before-bulk-rows"
    output_path = f"{current_dir}/entityDefs/TESTPERM.json.bulk-rows-adjusted"
    
    # Verify input file exists
    if not os.path.exists(json_path):
        print(f"❌ ERROR: Input file not found: {json_path}")
        sys.exit(1)
    
    # Create backup
    print(f"\n{'='*80}")
    print("💾 Creating Backup")
    print(f"{'='*80}\n")
    import shutil
    shutil.copy2(json_path, backup_path)
    print(f"✅ Backup created: {backup_path}\n")
    
    # Run the adjustment
    results = adjust_testperm_rows(json_path, output_path)
    
    # Final instructions
    print(f"\n{'='*80}")
    print("📋 NEXT STEPS")
    print(f"{'='*80}")
    print("1. Review the output file:")
    print(f"   {output_path}")
    print("\n2. If satisfied, replace the original:")
    print(f"   cp {output_path} {json_path}")
    print("\n3. Deploy to sandbox and rebuild")
    print("\n4. Test in browser (Ctrl+Shift+R to hard refresh)")
    print("\n5. Commit to GitHub")
    print(f"{'='*80}\n")

