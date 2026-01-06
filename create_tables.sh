#!/bin/bash

# Default values
LOCATION="US"

# Function to display usage
usage() {
    echo "Usage: $0 -p PROJECT_ID -d DATASET [-l LOCATION]"
    echo "  -p PROJECT_ID   Google Cloud Project ID"
    echo "  -d DATASET      BigQuery Dataset Name"
    echo "  -l LOCATION     BigQuery Location (default: US)"
    exit 1
}

# Parse command line arguments
while getopts "p:d:l:" opt; do
    case $opt in
        p) PROJECT_ID="$OPTARG" ;;
        d) DATASET="$OPTARG" ;;
        l) LOCATION="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check required arguments
if [ -z "$PROJECT_ID" ] || [ -z "$DATASET" ]; then
    usage
fi

echo "Using Project: $PROJECT_ID"
echo "Using Dataset: $DATASET"
echo "Using Location: $LOCATION"

# Check if dataset exists, create if it doesn't
if bq show --project_id="$PROJECT_ID" "$DATASET" >/dev/null 2>&1; then
    echo "Dataset $DATASET already exists."
else
    echo "Creating dataset $DATASET..."
    bq mk --dataset --location="$LOCATION" --project_id="$PROJECT_ID" "$DATASET" || {
        echo "Error creating dataset"
        exit 1
    }
fi

# Create tables from JSON files
TABLES_DIR="./tables"

if [ ! -d "$TABLES_DIR" ]; then
    echo "Error: Tables directory '$TABLES_DIR' not found."
    exit 1
fi

for schema_file in "$TABLES_DIR"/*.json; do
    [ -e "$schema_file" ] || continue
    
    table_name=$(basename "$schema_file" .json)
    echo "Creating table: $table_name from $schema_file"
    
    # Check if table exists (optional, but good for idempotency or just fail if exists)
    # Using 'bq mk' will fail if table exists unless --force is used. 
    # For now, we'll let it try and report error if it exists.
    
    bq mk --table --project_id="$PROJECT_ID" "$DATASET.$table_name" "$schema_file"
done

echo "Done."
