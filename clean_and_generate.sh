#!/bin/bash

BASE_DIR="./policies"
RULES_JSON="./rules.json"

echo "🔧 Cleaning Rego packages and generating rules.json..."

# Start a fresh JSON array
echo "[" > "$RULES_JSON"
first=true

# Loop over all .rego files
find "$BASE_DIR" -type f -name "*.rego" | while read -r file; do
  # Read the package line
  pkg_line=$(grep -E "^package " "$file")

  # Clean rules.tf.* if needed
  if [[ $pkg_line == package\ rules.tf.* ]]; then
    new_pkg=$(echo "$pkg_line" | sed -E 's/package rules\.tf\./package /')
    sed -i "s|$pkg_line|$new_pkg|" "$file"
    pkg_line="$new_pkg"
    echo "✔️ Cleaned: $file"
  else
    echo "ℹ️ Already clean: $file"
  fi

  # Extract relative path and metadata
  rel_path=$(realpath --relative-to="$BASE_DIR" "$file" | sed 's|\\|/|g')
  cloud=$(echo "$rel_path" | cut -d/ -f1)
  rule_id=$(echo "$pkg_line" | sed 's/package //')
  label=$(echo "$rule_id" | awk -F. '{print toupper(substr($NF,1,1)) tolower(substr($NF,2))}')

  # Extract severity from anywhere in the file (meta block)
  severity=$(grep -E '"severity":' "$file" | sed -E 's/.*"severity": *"([^"]+)".*/\1/' | head -n1)
  if [[ -z "$severity" ]]; then
    severity="medium"
  fi

  # Comma separator between entries
  if [ "$first" = true ]; then
    first=false
  else
    echo "," >> "$RULES_JSON"
  fi

  # Write the rule entry
  cat <<EOF >> "$RULES_JSON"
  {
    "id": "$rule_id",
    "label": "$label",
    "cloud_provider": "$cloud",
    "severity": "$severity",
    "rego_path": "$rel_path"
  }
EOF
done

echo "]" >> "$RULES_JSON"
echo "✅ Done! rules.json written to: $RULES_JSON"
