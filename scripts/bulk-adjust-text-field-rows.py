#!/usr/bin/env python3
"""
Bulk Text Field Row Height Adjuster for EspoCRM
Safely adjusts all text/textarea field "rows" to 1 for compact UI display
"""

import json
import sys
from pathlib import Path

def adjust_text_field_rows(json_file_path, output_file_path, target_rows=1, exclude_fields=None):
    """
    Adjust rows attribute for all text/textarea fields in entity JSON
    
    Args:
        json_file_path: Path to entityDefs JSON file
        output_file_path: Path to write modified JSON
        target_rows: Target number of rows (default 1)
        exclude_fields: List of field names to skip
    """
    if exclude_fields is None:
        exclude_fields = []
    
    print(f"Loading {json_file_path}...")
    with open(json_file_path, 'r') as f:
        data = json.load(f)
    
    if 'fields' not in data:
        print("ERROR: No 'fields' key found in JSON")
        return False
    
    updated_count = 0
    skipped_count = 0
    unchanged_count = 0
    field_changes = []
    
    for field_name, field_def in data['fields'].items():
        # Skip excluded fields
        if field_name in exclude_fields:
            skipped_count += 1
            continue
        
        # Check if this is a text/textarea field
        field_type = field_def.get('type', '')
        if field_type in ['text', 'textarea']:
            current_rows = field_def.get('rows')
            
            # Skip if already at target
            if current_rows == target_rows:
                unchanged_count += 1
                continue
            
            # Skip wysiwyg fields (rich text editors)
            if field_def.get('isWysiwyg', False):
                skipped_count += 1
                print(f"  SKIP {field_name}: wysiwyg field")
                continue
            
            # Update rows
            old_rows = current_rows if current_rows else 'unset'
            field_def['rows'] = target_rows
            updated_count += 1
            field_changes.append((field_name, old_rows, target_rows))
            print(f"  ✓ {field_name}: rows {old_rows} → {target_rows}")
    
    # Write output
    print(f"\nWriting to {output_file_path}...")
    with open(output_file_path, 'w') as f:
        json.dump(data, f, indent=4)
    
    # Summary
    print(f"\n{'='*70}")
    print(f"SUMMARY:")
    print(f"{'='*70}")
    print(f"  Fields updated: {updated_count}")
    print(f"  Fields unchanged (already rows={target_rows}): {unchanged_count}")
    print(f"  Fields skipped (wysiwyg/excluded): {skipped_count}")
    print(f"  Total text fields: {updated_count + unchanged_count + skipped_count}")
    print(f"{'='*70}")
    
    if field_changes:
        print(f"\nFields that will be changed:")
        for fname, old, new in field_changes:
            print(f"  • {fname}: {old} → {new}")
    
    return True

if __name__ == "__main__":
    # Configuration
    sandbox_dir = Path("/home/falken/DEVOPS Dropbox/DEVOPS-KARL/CORE-v4/2-ESPOCRM/ESPO-AUTOMATION/espo-sandbox")
    
    # Input file
    json_path = sandbox_dir / "entityDefs" / "PWD.json"
    
    # Output file (create backup name)
    output_path = sandbox_dir / "entityDefs" / "PWD.json.bulk-rows-adjusted"
    
    # Fields to exclude (if any)
    # These fields need multi-row for long-form content
    exclude_fields = [
        'jobduties',           # Job duties - needs 20 rows
        'addendumjobduties',   # Addendum duties - needs 15 rows
        'addendumsoc',         # SOC addendum - needs 15 rows
        'addendumeduc',        # Education addendum - needs 15 rows
    ]
    
    print("="*70)
    print("BULK TEXT FIELD ROW HEIGHT ADJUSTER")
    print("="*70)
    print(f"Entity: PWD")
    print(f"Target rows: 1 (single line)")
    print(f"Excluded fields: {len(exclude_fields)}")
    print("="*70)
    print()
    
    # Run adjustment
    success = adjust_text_field_rows(
        json_path,
        output_path,
        target_rows=1,
        exclude_fields=exclude_fields
    )
    
    if success:
        print(f"\n✅ SUCCESS!")
        print(f"\nOutput written to: {output_path}")
        print(f"\nNext steps:")
        print(f"  1. Review the changes above")
        print(f"  2. Check the output file: {output_path}")
        print(f"  3. If approved, replace PWD.json with the new version")
        print(f"  4. Deploy to sandbox and test")
        sys.exit(0)
    else:
        print(f"\n❌ FAILED!")
        sys.exit(1)

