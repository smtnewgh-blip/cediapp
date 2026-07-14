#!/bin/bash

# Database Backup Script
# Creates compressed backups and manages retention

set -e

BACKUP_DIR="${BACKUP_DIR:-.}/backups"
RETENTION_DAYS=7
DB_NAME="cediapp"
DB_USER="postgres"

mkdir -p "$BACKUP_DIR"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting database backup..."

# Backup database
BACKUP_FILE="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).sql"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backing up database to: $BACKUP_FILE"

if command -v docker-compose &> /dev/null; then
    docker-compose exec -T postgres pg_dump -U $DB_USER $DB_NAME > "$BACKUP_FILE" 2>/dev/null
else
    pg_dump -U $DB_USER $DB_NAME > "$BACKUP_FILE"
fi

# Compress backup
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Compressing backup..."
gzip -f "$BACKUP_FILE"
BACKUP_FILE="$BACKUP_FILE.gz"

BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup complete: $BACKUP_FILE ($BACKUP_SIZE)"

# Cleanup old backups
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cleaning up old backups (retention: $RETENTION_DAYS days)..."
find "$BACKUP_DIR" -name "backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup process completed successfully"
