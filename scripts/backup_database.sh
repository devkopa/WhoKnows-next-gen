#!/bin/bash
# Database Backup Script for WhoKnows Application
# Usage: ./backup_database.sh

set -e

# Configuration
BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "Error: .env file not found"
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "Starting database backup..."
echo "Database: $POSTGRES_DB"
echo "Timestamp: $DATE"

# Create backup
BACKUP_FILE="$BACKUP_DIR/whoknows_backup_$DATE.sql"
docker-compose exec -T postgres pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > "$BACKUP_FILE"

# Compress backup
echo "Compressing backup..."
gzip "$BACKUP_FILE"
BACKUP_FILE="$BACKUP_FILE.gz"

# Check if backup was successful
if [ -f "$BACKUP_FILE" ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "Backup completed successfully!"
    echo "File: $BACKUP_FILE"
    echo "Size: $BACKUP_SIZE"
else
    echo "Error: Backup failed"
    exit 1
fi

# Remove old backups
echo "Cleaning up old backups (older than $RETENTION_DAYS days)..."
find "$BACKUP_DIR" -name "whoknows_backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete
echo "Cleanup completed"

# List current backups
echo ""
echo "Current backups:"
ls -lh "$BACKUP_DIR"/whoknows_backup_*.sql.gz | tail -5

echo ""
echo "Backup process completed successfully!"
