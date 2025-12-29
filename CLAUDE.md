# TrinityCore 3.3.5 Custom Server Project

This is a customized TrinityCore 3.3.5 (WotLK) private server with extensive custom features.

## Project Structure

```
testwow1/
├── TrinityCore/           # Forked TrinityCore submodule (3.3.5 branch)
├── sql/custom/            # Custom SQL files
├── configs/               # Server configuration files
├── scripts/               # Build and setup scripts
├── docker-compose.yml     # Docker setup
└── README.md
```

## Custom Features

### 1. Haste & Avoidance Caps
- **Haste**: 2000 rating = 100% (instant attacks)
- **Dodge cap**: 80%
- **Parry cap**: 80%
- **Block cap**: 30%

Files: `TrinityCore/src/server/game/Entities/Player/Player.cpp`, `Unit.cpp`

### 2. Auto-Loot System
- Mobs auto-looted on death
- Group members each get 1 of each item
- Roll flag for dev-specified items (`ITEM_FLAGS_CU_FORCE_GROUP_ROLL`)

### 3. Loot Logging
- GM commands: `.loot log player/recent/item/suspicious`
- Database table: `custom_loot_log`

File: `TrinityCore/src/server/scripts/Commands/cs_loot.cpp`

### 4. Magic Stone Teleporter
- Right-click item opens gossip menu
- Database-configurable destinations with categories
- Custom colors and icons

Files:
- `TrinityCore/src/server/scripts/Custom/item_magic_stone.cpp`
- `sql/custom/02_magic_stone_teleporter.sql`

### 5. Artifact Weapon System
- Database-driven weapon progression with tiers
- EXP from kills, bosses, quests, PvP
- Visual effects and server announcements

Files:
- `TrinityCore/src/server/scripts/Custom/item_artifact_weapon.cpp`
- `sql/custom/03_artifact_weapons.sql`

### 6. World Chat System
- 10 player ranks based on /played time
- Staff ranks (Trial GM, Gamemaster, Admin, Owner)
- Class-colored names, badges, cooldowns
- Uses standard account mute system

Commands:
- `# message` or `.chat message` - Send to world chat
- `.chat on/off` - Toggle world chat
- `.chat info` - View rank info

Files:
- `TrinityCore/src/server/scripts/Custom/cs_world_chat.cpp`
- `sql/custom/04_world_chat.sql`

### 7. Tower Defense System
- Wave-based defense events
- Configurable arenas, waves, spawn points
- Scaling rewards per wave
- Progress tracking per player

Commands: Talk to Tower Defense NPC

Files:
- `TrinityCore/src/server/scripts/Custom/npc_tower_defense.cpp`
- `sql/custom/06_tower_defense.sql`

### 8. Hot-Reload Commands
- `.reload custom all` - Reload all custom tables
- `.reload custom teleport` - Reload Magic Stone data
- `.reload custom artifact` - Reload Artifact Weapons
- `.reload custom worldchat` - Reload World Chat
- `.reload custom towerdefense` - Reload Tower Defense

## Custom Scripts Location

All custom scripts are in:
```
TrinityCore/src/server/scripts/Custom/
├── custom_systems.h           # Shared managers (singleton pattern)
├── custom_script_loader.cpp   # Script registration
├── cs_custom_reload.cpp       # Reload commands
├── cs_world_chat.cpp          # World chat system
├── cs_loot.cpp                # Loot logging commands
├── item_magic_stone.cpp       # Teleporter item
├── item_artifact_weapon.cpp   # Artifact weapons
└── npc_tower_defense.cpp      # Tower defense system
```

## Database Tables

### World Database
- `custom_teleport_categories` - Teleport categories
- `custom_teleport_destinations` - Teleport locations
- `custom_artifact_weapons` - Artifact weapon definitions
- `custom_artifact_weapon_tiers` - Tier progression data
- `custom_world_chat_settings` - Chat settings
- `custom_world_chat_ranks` - Player ranks (by /played)
- `custom_staff_ranks` - Staff ranks (by security level)
- `custom_staff_rank_overrides` - Per-account custom titles
- `custom_tower_defense_arenas` - Defense arenas
- `custom_tower_defense_waves` - Wave definitions
- `custom_tower_defense_rewards` - Wave rewards
- `custom_tower_defense_spawn_points` - Mob spawn points

### Character Database
- `custom_loot_log` - Loot tracking
- `character_world_chat` - Player chat preferences
- `character_artifact_weapons` - Player weapon progress
- `custom_tower_defense_progress` - Player TD progress

### Auth Database
- `rbac_default_permissions` - Security level permissions
- `rbac_linked_permissions` - Permission links
- `account_access` - Account security levels

## Staff Ranks & Permissions

| Rank | Level | Key Permissions |
|------|-------|-----------------|
| Trial GM | 1 | Kick, mute, `.gm`, `.tele` |
| Gamemaster | 2 | + Ban, items, spawning |
| Admin | 3 | + Reload, server, accounts |
| Owner | 4 | Full access |

Set security level:
```sql
INSERT INTO account_access (id, gmlevel, RealmID)
VALUES (<account_id>, <level>, -1);
```

## Building

```bash
cd TrinityCore
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/opt/trinity
make -j$(nproc)
make install
```

## Applying Custom SQL

```bash
# World database
mysql -u root -p world < sql/custom/02_magic_stone_teleporter.sql
mysql -u root -p world < sql/custom/03_artifact_weapons.sql
mysql -u root -p world < sql/custom/04_world_chat.sql
mysql -u root -p world < sql/custom/06_tower_defense.sql

# Auth database
mysql -u root -p auth < sql/custom/05_staff_rbac_permissions.sql

# Character database
mysql -u root -p characters < sql/custom/01_loot_log_table.sql
```

## Adding New Custom Scripts

1. Create script file in `TrinityCore/src/server/scripts/Custom/`
2. Add `void AddSC_your_script();` declaration in `custom_script_loader.cpp`
3. Call `AddSC_your_script();` in `AddCustomScripts()`
4. If using a manager, add it to `custom_systems.h`
5. Add reload support in `cs_custom_reload.cpp`

## Notes

- TrinityCore is a git submodule pointing to your fork
- All customizations use database-driven configuration
- Use `.reload custom` commands to apply changes without restart
- Custom scripts use the singleton manager pattern for caching
