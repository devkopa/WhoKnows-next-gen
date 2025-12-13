#!/bin/bash
# Database Restore Script for WhoKnows Application
# Usage: ./restore_database.sh <backup_file>

set -e

# Check if backup file was provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <backup_file>"
    echo ""
    echo "Available backups:"
    ls -lh ./backups/whoknows_backup_*.sql.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_FILE=$1

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "Error: .env file not found"
    exit 1
fi

echo "WARNING: This will overwrite the current database!"
echo "Database: $POSTGRES_DB"
echo "Backup file: $BACKUP_FILE"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Restore cancelled"
    exit 0
fi

echo "Starting database restore..."

# Create temporary uncompressed file if needed
if [[ $BACKUP_FILE == *.gz ]]; then
    echo "Decompressing backup..."
    TEMP_FILE="/tmp/restore_temp_$(date +%s).sql"
    gunzip -c "$BACKUP_FILE" > "$TEMP_FILE"
    RESTORE_FILE="$TEMP_FILE"
else
    RESTORE_FILE="$BACKUP_FILE"
fi

# Drop and recreate database
echo "Recreating database..."
docker-compose exec -T postgres psql -U "$POSTGRES_USER" -d postgres <<EOF
DROP DATABASE IF EXISTS $POSTGRES_DB;
CREATE DATABASE $POSTGRES_DB;
EOF

# Restore database
echo "Restoring database..."
cat "$RESTORE_FILE" | docker-compose exec -T postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"

# Clean up temporary file
if [ ! -z "$TEMP_FILE" ]; then
    rm -f "$TEMP_FILE"
fi

echo ""
echo "Database restore completed successfully!"
echo ""
echo "Next steps:"
echo "1. Restart the application: docker-compose restart web"
echo "2. Verify application functionality"
echo "3. Check logs: docker-compose logs web"
