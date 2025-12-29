#!/bin/bash
###############################################################################
# TrinityCore 3.3.5 Build Script
###############################################################################

set -e

# Configuration
TRINITY_REPO="https://github.com/TrinityCore/TrinityCore.git"
TRINITY_BRANCH="3.3.5"
SOURCE_DIR="${SOURCE_DIR:-$HOME/TrinityCore}"
BUILD_DIR="${BUILD_DIR:-$SOURCE_DIR/build}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/server}"
JOBS="${JOBS:-$(nproc)}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."

    local deps=(git cmake make gcc g++ clang)
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing[*]}"
        log_info "Install them with: sudo apt install ${missing[*]}"
        exit 1
    fi

    log_info "All dependencies found!"
}

# Clone or update source
clone_source() {
    if [ -d "$SOURCE_DIR" ]; then
        log_info "Source directory exists, updating..."
        cd "$SOURCE_DIR"
        git fetch origin
        git checkout "$TRINITY_BRANCH"
        git pull origin "$TRINITY_BRANCH"
    else
        log_info "Cloning TrinityCore $TRINITY_BRANCH..."
        git clone -b "$TRINITY_BRANCH" "$TRINITY_REPO" "$SOURCE_DIR"
    fi
}

# Configure build
configure_build() {
    log_info "Configuring build..."

    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    cmake "$SOURCE_DIR" \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
        -DCMAKE_C_COMPILER=/usr/bin/clang \
        -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
        -DWITH_WARNINGS=1 \
        -DTOOLS=1 \
        -DSCRIPTS=static
}

# Build
build() {
    log_info "Building TrinityCore with $JOBS jobs..."
    cd "$BUILD_DIR"
    make -j"$JOBS"
}

# Install
install() {
    log_info "Installing to $INSTALL_DIR..."
    cd "$BUILD_DIR"
    make install
}

# Main execution
main() {
    log_info "=== TrinityCore 3.3.5 Build Script ==="
    log_info "Source: $SOURCE_DIR"
    log_info "Build:  $BUILD_DIR"
    log_info "Install: $INSTALL_DIR"
    log_info "Jobs: $JOBS"
    echo ""

    check_dependencies
    clone_source
    configure_build
    build
    install

    log_info "=== Build Complete! ==="
    log_info "Server installed to: $INSTALL_DIR"
    log_info ""
    log_info "Next steps:"
    log_info "1. Set up the database: ./scripts/setup-database.sh"
    log_info "2. Extract client data: ./scripts/extract-data.sh"
    log_info "3. Configure server files in $INSTALL_DIR/etc/"
    log_info "4. Start servers from $INSTALL_DIR/bin/"
}

main "$@"
