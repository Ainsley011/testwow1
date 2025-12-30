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
- **Account Info Tab**: View donation/vote points, open bank & mailbox

Features:
- Teleport categories with faction/level restrictions
- GM-only destinations
- Account Info submenu with:
  - Donation Points display
  - Vote Points display
  - Open Bank (anywhere)
  - Open Mailbox (anywhere)

Files:
- `TrinityCore/src/server/scripts/Custom/item_magic_stone.cpp`
- `sql/custom/02_magic_stone_teleporter.sql`
- `sql/custom/08_account_points.sql`

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
- **Checkpoints**: Start from previously beaten waves (3, 5, 7...)
- **Leaderboards**: Top 10 fastest completion times
- **AFK Detection**: Inactive players removed after 2 minutes
- **Mob Death Hooks**: Proper wave completion tracking
- **Defender Damage**: Mobs damage the defender when in range

Features:
- Talk to NPC to start, view progress, or check leaderboard
- Checkpoint system unlocks at waves 3, 5, 7, 9, etc.
- Mobs automatically attack the defender object
- Player activity tracked (kills, spells) for AFK detection

Files:
- `TrinityCore/src/server/scripts/Custom/npc_tower_defense.cpp`
- `sql/custom/06_tower_defense.sql`

### 8. Hot-Reload Commands
- `.reload custom all` - Reload all custom tables
- `.reload custom teleport` - Reload Magic Stone data
- `.reload custom artifact` - Reload Artifact Weapons
- `.reload custom worldchat` - Reload World Chat
- `.reload custom towerdefense` - Reload Tower Defense

### 9. Vote Buff System
- **+10% all stats** buff when voted on all 4 sites
- Buff automatically expires after 12 hours (vote cooldown)
- Tracks votes per site per account
- Announces to server when player receives buff

Commands:
- `.vote status` - Check your vote status
- `.vote sites` - List voting site URLs
- `.vote grant <player> <site_id>` - GM: Simulate a vote

Files:
- `TrinityCore/src/server/scripts/Custom/vote_buff_system.cpp`
- `sql/custom/08_account_points.sql`

### 10. Transmogrification System
- Change gear appearance via NPC
- Requires compatible item types
- Configurable gold/token costs
- Persists across sessions

Features:
- Select slot, choose from inventory items
- Remove individual or all transmogs
- Quality-colored item names
- Same armor type requirement (configurable)

Files:
- `TrinityCore/src/server/scripts/Custom/npc_transmogrifier.cpp`
- `sql/custom/09_new_systems.sql`

### 11. Mythic+ Dungeon System
- Scaling difficulty dungeons with keystones
- Weekly rotating affixes (Fortified, Tyrannical, etc.)
- Timer-based runs with leaderboards
- 10%+ scaling per level

Features:
- Keystones earned from dungeons
- 3 affixes at +2, +4, +7
- Leaderboard per dungeon
- Group requirement for runs

Commands:
- `.mythic info` - View your keystone
- `.mythic keystone <dungeonId> <level> [player]` - GM: Grant keystone

Files:
- `TrinityCore/src/server/scripts/Custom/mythic_plus_system.cpp`
- `sql/custom/09_new_systems.sql`

### 12. Custom Titles System
- Purchasable/earnable titles with **5-25% stat bonuses**
- Multiple acquisition methods (gold, points, kills)
- Account-wide title collection
- Server announcements for high-tier titles

Stat Bonus Tiers:
- 5%: Basic titles (500g or 50 VP)
- 10%: Veteran titles (2-5M gold, 1000+ kills)
- 15%: Champion titles (10M gold, 50 DP)
- 20%: Legend titles (50M gold, 100 DP)
- 25%: Ascendant titles (200 DP, ultimate)

Commands:
- `.title list` - List all titles
- `.title grant <titleId> [player]` - GM: Grant title

Files:
- `TrinityCore/src/server/scripts/Custom/custom_titles_system.cpp`
- `sql/custom/09_new_systems.sql`

### 13. Staff Activity Log
- Logs all GM commands for auditing
- Categorizes commands (player, item, ban, spawn, etc.)
- Searchable log history
- Configurable minimum security level

Commands:
- `.stafflog recent [limit]` - View recent activity
- `.stafflog account <name> [limit]` - View staff member's activity
- `.stafflog category <type> [limit]` - Filter by category
- `.stafflog search <keyword>` - Search logs

Files:
- `TrinityCore/src/server/scripts/Custom/staff_activity_log.cpp`
- `sql/custom/09_new_systems.sql`

### 14. Server Statistics System
- Real-time and historical server stats
- Population, economy, combat, PvP tracking
- Daily activity metrics
- NPC and command access

Stats Tracked:
- Online players (faction split)
- Total accounts/characters
- Gold in circulation
- Mobs/bosses killed
- Arena/BG matches
- Quest completions

Commands:
- `.serverstats` - Quick server overview

Files:
- `TrinityCore/src/server/scripts/Custom/server_stats_system.cpp`
- `sql/custom/09_new_systems.sql`

### 15. Changelog System
- Display server updates to players
- Category-based organization
- Unread notification on login
- Paginated browsing

Categories:
- Features, Bug Fixes, Balance, Content, Events, Hotfixes

Commands:
- `.changelog` - View recent updates
- `.changelog add <cat> <ver> <title> | <desc>` - Add entry
- `.changelog reload` - Reload entries

Files:
- `TrinityCore/src/server/scripts/Custom/npc_changelog.cpp`
- `sql/custom/09_new_systems.sql`

### 16. Talent Prestige System
- Earn **bonus talent points** through prestige levels
- Account-wide progression
- Multiple requirement types (playtime, kills, etc.)
- Up to +10 bonus talent points

Prestige Levels:
- Level 1: 1 max char (+1 point)
- Level 5: 1000 HKs (+1 point)
- Level 10: 10000 HKs (+2 points)

Commands:
- `.prestige info` - View your prestige status
- `.prestige grant <player>` - GM: Grant next level

Files:
- `TrinityCore/src/server/scripts/Custom/talent_prestige_system.cpp`
- `sql/custom/09_new_systems.sql`

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
├── npc_tower_defense.cpp      # Tower defense system
├── npc_vip_system.cpp         # VIP system
├── vote_buff_system.cpp       # Vote buff system
├── npc_transmogrifier.cpp     # Transmog system
├── mythic_plus_system.cpp     # Mythic+ dungeons
├── custom_titles_system.cpp   # Custom titles with stat bonuses
├── staff_activity_log.cpp     # GM command logging
├── server_stats_system.cpp    # Server statistics
├── npc_changelog.cpp          # Changelog display
└── talent_prestige_system.cpp # Talent prestige
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
- `custom_vote_sites` - Voting site configuration
- `custom_vote_buff_settings` - Vote buff settings
- `custom_transmog_settings` - Transmog cost/rules
- `custom_mythic_dungeons` - Mythic+ dungeon definitions
- `custom_mythic_affix_rotation` - Weekly affix rotation
- `custom_titles` - Custom titles with stat bonuses
- `custom_staff_log_settings` - Staff log configuration
- `custom_changelog` - Server changelog entries
- `custom_talent_prestige_levels` - Prestige level definitions
- `custom_talent_prestige_settings` - Prestige system settings

### Character Database
- `custom_loot_log` - Loot tracking
- `character_world_chat` - Player chat preferences
- `character_artifact_weapons` - Player weapon progress
- `custom_tower_defense_progress` - Player TD progress
- `account_points` - Donation and vote points per account
- `account_points_history` - Transaction history for auditing
- `account_vote_tracker` - Vote timestamps per site for Vote Buff
- `character_transmog` - Player transmog appearances
- `character_mythic_keystone` - Player keystones
- `custom_mythic_leaderboard` - Mythic+ run times
- `character_custom_titles` - Owned titles
- `character_custom_title_active` - Active title per character
- `custom_staff_activity_log` - GM command history
- `custom_server_stats_daily` - Daily server stats
- `custom_server_stats_alltime` - All-time server stats
- `character_changelog_read` - Changelog read tracking
- `account_talent_prestige` - Account prestige levels

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
mysql -u root -p world < sql/custom/09_new_systems.sql

# Auth database
mysql -u root -p auth < sql/custom/05_staff_rbac_permissions.sql

# Character database
mysql -u root -p characters < sql/custom/01_loot_log_table.sql
mysql -u root -p characters < sql/custom/07_vip_system.sql
mysql -u root -p characters < sql/custom/08_account_points.sql
# Note: Character tables from 09_new_systems.sql are commented out
# Uncomment and run them on the character database
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
