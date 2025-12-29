# TrinityCore 3.3.5 WoW Server

A World of Warcraft server based on TrinityCore for the 3.3.5a (Wrath of the Lich King) client.

## Requirements

### System Requirements
- **OS**: Ubuntu 22.04 LTS / Debian 12 (recommended) or Windows 10/11
- **RAM**: Minimum 4GB, recommended 8GB+
- **Storage**: 25GB+ free space
- **CPU**: Multi-core processor recommended

### Software Dependencies

#### Ubuntu/Debian
```bash
sudo apt update && sudo apt install -y \
    git clang cmake make gcc g++ libmysqlclient-dev \
    libssl-dev libbz2-dev libreadline-dev libncurses-dev \
    libboost-all-dev mysql-server p7zip-full
```

#### Windows
- Visual Studio 2022 (with C++ workload)
- CMake 3.18+
- OpenSSL 1.1.x
- MySQL 8.0
- Boost 1.78+
- Git

## Quick Start

### Option 1: Docker (Recommended)
```bash
# Start the server stack
docker-compose up -d

# View logs
docker-compose logs -f
```

### Option 2: Manual Installation

#### 1. Clone Repository with Submodules
```bash
git clone --recursive https://github.com/Ainsley011/testwow1.git
cd testwow1

# Or if already cloned, initialize submodules:
git submodule update --init --recursive
```

#### 2. Build the Server
```bash
# Use the provided build script
./scripts/build.sh

# Or manually:
mkdir build && cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=$HOME/server
make -j$(nproc)
make install
```

#### 3. Database Setup
```bash
# Run database setup script
./scripts/setup-database.sh
```

#### 4. Extract Client Data
You need a 3.3.5a (12340) WoW client to extract maps, vmaps, mmaps, and dbc files.

```bash
cd ~/server/bin
./mapextractor
./vmap4extractor
./vmap4assembler Buildings vmaps
./mmaps_generator
```

#### 5. Configure Server
```bash
# Copy configuration templates
cp configs/worldserver.conf.dist ~/server/etc/worldserver.conf
cp configs/authserver.conf.dist ~/server/etc/authserver.conf

# Edit configurations as needed
nano ~/server/etc/worldserver.conf
nano ~/server/etc/authserver.conf
```

#### 6. Start the Server
```bash
# Start auth server
./authserver &

# Start world server
./worldserver
```

## Project Structure

```
.
├── TrinityCore/             # TrinityCore source (git submodule)
├── configs/                 # Server configuration templates
│   ├── worldserver.conf.dist
│   └── authserver.conf.dist
├── scripts/                 # Utility scripts
│   ├── build.sh            # Build script
│   ├── setup-database.sh   # Database setup
│   └── extract-data.sh     # Client data extraction
├── sql/                     # Custom SQL modifications
│   └── custom/
├── docker-compose.yml       # Docker deployment
└── README.md
```

## Modifying the Core

The TrinityCore source is included as a git submodule pointing to your fork. To make changes:

```bash
cd TrinityCore
# Make your changes
git add .
git commit -m "Your changes"
git push origin 3.3.5
```

To pull upstream TrinityCore updates:
```bash
cd TrinityCore
git remote add upstream https://github.com/TrinityCore/TrinityCore.git
git fetch upstream
git merge upstream/3.3.5
# Resolve conflicts if any, then push to your fork
git push origin 3.3.5
```

## Default Accounts

| Account | Password | Access Level |
|---------|----------|--------------|
| admin   | admin    | GM (3)       |

**Important**: Change default passwords before production use!

## Connecting to Your Server

1. Set your WoW 3.3.5a client realmlist:
   ```
   SET realmlist "127.0.0.1"
   ```
   (Edit `Data/enUS/realmlist.wtf` or equivalent for your locale)

2. Launch WoW and login with your account

## Common Commands

### In-Game GM Commands
```
.account create <name> <password>
.account set gmlevel <name> 3 -1
.server info
.lookup item <name>
.additem <itemid>
.tele <location>
```

### Server Console Commands
```
account create <name> <password>
account set gmlevel <name> 3 -1
server info
server shutdown <seconds>
```

## Troubleshooting

### Database Connection Issues
- Verify MySQL is running: `sudo systemctl status mysql`
- Check credentials in config files
- Ensure database user has proper permissions

### Map/Data Errors
- Ensure all data files are extracted and in correct locations
- Verify client version is 3.3.5a (build 12340)

### Build Errors
- Update dependencies: `sudo apt update && sudo apt upgrade`
- Clean build: `rm -rf build && mkdir build`
- Check CMake output for missing dependencies

## Resources

- [TrinityCore Wiki](https://trinitycore.info/)
- [TrinityCore GitHub](https://github.com/TrinityCore/TrinityCore)
- [TrinityCore Discord](https://discord.gg/trinitycore)

## License

This project setup is provided as-is. TrinityCore is licensed under GPL v2.
