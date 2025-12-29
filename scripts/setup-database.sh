#!/bin/bash
###############################################################################
# TrinityCore 3.3.5 Database Setup Script
###############################################################################

set -e

# Configuration
MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_USER="${MYSQL_USER:-trinity}"
MYSQL_PASS="${MYSQL_PASS:-trinity}"
MYSQL_ROOT_USER="${MYSQL_ROOT_USER:-root}"
MYSQL_ROOT_PASS="${MYSQL_ROOT_PASS:-}"

SOURCE_DIR="${SOURCE_DIR:-$HOME/TrinityCore}"

# Database names
DB_AUTH="auth"
DB_CHARACTERS="characters"
DB_WORLD="world"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# MySQL command helper
mysql_cmd() {
    if [ -n "$MYSQL_ROOT_PASS" ]; then
        mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASS" "$@"
    else
        mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_ROOT_USER" "$@"
    fi
}

# Check MySQL connection
check_mysql() {
    log_info "Checking MySQL connection..."
    if ! mysql_cmd -e "SELECT 1" &> /dev/null; then
        log_error "Cannot connect to MySQL. Check your credentials."
        exit 1
    fi
    log_info "MySQL connection successful!"
}

# Create databases and user
create_databases() {
    log_info "Creating databases..."

    mysql_cmd <<EOF
-- Create databases
CREATE DATABASE IF NOT EXISTS \`$DB_AUTH\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS \`$DB_CHARACTERS\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS \`$DB_WORLD\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user and grant permissions
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASS';
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASS';

GRANT ALL PRIVILEGES ON \`$DB_AUTH\`.* TO '$MYSQL_USER'@'localhost';
GRANT ALL PRIVILEGES ON \`$DB_CHARACTERS\`.* TO '$MYSQL_USER'@'localhost';
GRANT ALL PRIVILEGES ON \`$DB_WORLD\`.* TO '$MYSQL_USER'@'localhost';

GRANT ALL PRIVILEGES ON \`$DB_AUTH\`.* TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES ON \`$DB_CHARACTERS\`.* TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES ON \`$DB_WORLD\`.* TO '$MYSQL_USER'@'%';

FLUSH PRIVILEGES;
EOF

    log_info "Databases created successfully!"
}

# Import base SQL files
import_base_sql() {
    log_info "Importing base SQL files..."

    local sql_dir="$SOURCE_DIR/sql"

    if [ ! -d "$sql_dir" ]; then
        log_error "SQL directory not found: $sql_dir"
        log_info "Make sure TrinityCore is cloned to: $SOURCE_DIR"
        exit 1
    fi

    # Import auth database
    if [ -f "$sql_dir/base/auth_database.sql" ]; then
        log_info "Importing auth database..."
        mysql_cmd "$DB_AUTH" < "$sql_dir/base/auth_database.sql"
    fi

    # Import characters database
    if [ -f "$sql_dir/base/characters_database.sql" ]; then
        log_info "Importing characters database..."
        mysql_cmd "$DB_CHARACTERS" < "$sql_dir/base/characters_database.sql"
    fi

    log_info "Base SQL files imported!"
}

# Download and import world database
import_world_database() {
    log_info "World database needs to be downloaded from TrinityCore releases."
    log_info "Visit: https://github.com/TrinityCore/TrinityCore/releases"
    log_info "Download the TDB (TrinityCore Database) for 3.3.5"
    log_info ""
    log_info "After downloading, import with:"
    log_info "  mysql -u $MYSQL_USER -p $DB_WORLD < TDB_full_world_335.XX_20XX_XX_XX.sql"
}

# Create default GM account
create_admin_account() {
    log_info "Creating default admin account..."

    mysql_cmd "$DB_AUTH" <<EOF
-- Create admin account (password: admin, SHA1 hash)
INSERT INTO account (username, sha_pass_hash, expansion)
VALUES ('ADMIN', SHA1(CONCAT(UPPER('ADMIN'), ':', UPPER('admin'))), 2)
ON DUPLICATE KEY UPDATE sha_pass_hash = SHA1(CONCAT(UPPER('ADMIN'), ':', UPPER('admin')));

-- Set admin account to GM level 3
INSERT INTO account_access (id, gmlevel, RealmID)
SELECT id, 3, -1 FROM account WHERE username = 'ADMIN'
ON DUPLICATE KEY UPDATE gmlevel = 3;
EOF

    log_info "Admin account created (username: admin, password: admin)"
    log_warn "CHANGE THIS PASSWORD IN PRODUCTION!"
}

# Set up default realm
setup_realm() {
    log_info "Setting up default realm..."

    mysql_cmd "$DB_AUTH" <<EOF
-- Update or insert default realm
INSERT INTO realmlist (id, name, address, localAddress, localSubnetMask, port, icon, flag, timezone, allowedSecurityLevel, population, gamebuild)
VALUES (1, 'TrinityCore', '127.0.0.1', '127.0.0.1', '255.255.255.0', 8085, 0, 0, 1, 0, 0, 12340)
ON DUPLICATE KEY UPDATE
    name = 'TrinityCore',
    address = '127.0.0.1',
    port = 8085,
    gamebuild = 12340;
EOF

    log_info "Default realm configured!"
}

# Main
main() {
    log_info "=== TrinityCore 3.3.5 Database Setup ==="
    echo ""

    check_mysql
    create_databases
    import_base_sql
    create_admin_account
    setup_realm

    echo ""
    log_info "=== Database Setup Complete! ==="
    echo ""
    import_world_database
}

main "$@"
