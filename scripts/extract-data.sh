#!/bin/bash
###############################################################################
# TrinityCore 3.3.5 Client Data Extraction Script
###############################################################################

set -e

# Configuration
INSTALL_DIR="${INSTALL_DIR:-$HOME/server}"
CLIENT_DIR="${CLIENT_DIR:-}"
DATA_DIR="${DATA_DIR:-$INSTALL_DIR/data}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
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

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Check for client directory
check_client() {
    if [ -z "$CLIENT_DIR" ]; then
        log_error "CLIENT_DIR not set!"
        echo ""
        echo "Usage: CLIENT_DIR=/path/to/wow/client $0"
        echo ""
        echo "The client directory should contain:"
        echo "  - Data/ folder"
        echo "  - Wow.exe"
        echo ""
        echo "Required client version: 3.3.5a (build 12340)"
        exit 1
    fi

    if [ ! -d "$CLIENT_DIR/Data" ]; then
        log_error "Invalid client directory: $CLIENT_DIR"
        log_error "Data folder not found!"
        exit 1
    fi

    log_info "Client directory: $CLIENT_DIR"
}

# Check for extractors
check_extractors() {
    local bin_dir="$INSTALL_DIR/bin"
    local missing=()

    for tool in mapextractor vmap4extractor vmap4assembler mmaps_generator; do
        if [ ! -f "$bin_dir/$tool" ]; then
            missing+=("$tool")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing extractor tools: ${missing[*]}"
        log_info "Build TrinityCore with TOOLS=1 to generate extractors"
        exit 1
    fi

    log_info "All extractor tools found!"
}

# Extract DBC files
extract_dbc() {
    log_step "Extracting DBC files..."

    cd "$CLIENT_DIR"
    "$INSTALL_DIR/bin/mapextractor"

    mkdir -p "$DATA_DIR"
    mv dbc "$DATA_DIR/" 2>/dev/null || true
    mv maps "$DATA_DIR/" 2>/dev/null || true

    log_info "DBC and maps extracted!"
}

# Extract vmaps
extract_vmaps() {
    log_step "Extracting VMaps (this may take a while)..."

    cd "$CLIENT_DIR"
    "$INSTALL_DIR/bin/vmap4extractor"

    mkdir -p Buildings
    "$INSTALL_DIR/bin/vmap4assembler" Buildings vmaps

    mv vmaps "$DATA_DIR/" 2>/dev/null || true
    rm -rf Buildings

    log_info "VMaps extracted!"
}

# Generate mmaps
generate_mmaps() {
    log_step "Generating MMaps (this will take several hours)..."
    log_warn "This is optional but recommended for proper pathfinding."

    read -p "Generate MMaps? This takes 2-4 hours. (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        cd "$CLIENT_DIR"
        mkdir -p mmaps
        "$INSTALL_DIR/bin/mmaps_generator"
        mv mmaps "$DATA_DIR/" 2>/dev/null || true
        log_info "MMaps generated!"
    else
        log_info "Skipping MMap generation."
        log_warn "You can generate them later by running this script again."
    fi
}

# Cleanup
cleanup() {
    log_step "Cleaning up..."

    cd "$CLIENT_DIR"
    rm -rf Buildings 2>/dev/null || true

    log_info "Cleanup complete!"
}

# Verify extraction
verify() {
    log_step "Verifying extracted data..."

    local required_dirs=("dbc" "maps")
    local optional_dirs=("vmaps" "mmaps")
    local ok=true

    for dir in "${required_dirs[@]}"; do
        if [ -d "$DATA_DIR/$dir" ]; then
            log_info "  $dir: OK"
        else
            log_error "  $dir: MISSING"
            ok=false
        fi
    done

    for dir in "${optional_dirs[@]}"; do
        if [ -d "$DATA_DIR/$dir" ]; then
            log_info "  $dir: OK"
        else
            log_warn "  $dir: Not found (optional)"
        fi
    done

    if [ "$ok" = true ]; then
        log_info "Data extraction verified!"
    else
        log_error "Some required data is missing!"
        exit 1
    fi
}

# Print summary
summary() {
    echo ""
    log_info "=== Extraction Complete ==="
    echo ""
    echo "Data directory: $DATA_DIR"
    echo ""
    echo "Contents:"
    ls -la "$DATA_DIR" 2>/dev/null || echo "  (empty)"
    echo ""
    log_info "Update your worldserver.conf:"
    log_info "  DataDir = \"$DATA_DIR\""
}

# Main
main() {
    echo ""
    log_info "=== TrinityCore 3.3.5 Data Extraction ==="
    echo ""

    check_client
    check_extractors

    echo ""
    log_info "This script will extract:"
    log_info "  1. DBC files (database client files)"
    log_info "  2. Maps (world terrain)"
    log_info "  3. VMaps (visual maps for line-of-sight)"
    log_info "  4. MMaps (movement maps for pathfinding) - Optional"
    echo ""

    read -p "Continue? (Y/n): " confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        log_info "Aborted."
        exit 0
    fi

    extract_dbc
    extract_vmaps
    generate_mmaps
    cleanup
    verify
    summary
}

main "$@"
