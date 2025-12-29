-- ============================================================================
-- TOWER DEFENSE SYSTEM
-- Wave-based defense event where players protect an object from mob waves
-- ============================================================================

-- ============================================================================
-- TOWER DEFENSE ARENAS
-- Defines locations where tower defense events can take place
-- ============================================================================

DROP TABLE IF EXISTS `custom_tower_defense_arenas`;
CREATE TABLE `custom_tower_defense_arenas` (
    `arena_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL COMMENT 'Arena display name',
    `description` TEXT DEFAULT NULL,
    `map_id` SMALLINT UNSIGNED NOT NULL,
    `min_players` TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `max_players` TINYINT UNSIGNED NOT NULL DEFAULT 5,
    `min_level` TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `max_level` TINYINT UNSIGNED NOT NULL DEFAULT 80,
    -- Defender object position (what players protect)
    `defender_entry` INT UNSIGNED NOT NULL COMMENT 'GameObject or Creature entry to defend',
    `defender_is_creature` TINYINT(1) NOT NULL DEFAULT 0,
    `defender_x` FLOAT NOT NULL,
    `defender_y` FLOAT NOT NULL,
    `defender_z` FLOAT NOT NULL,
    `defender_o` FLOAT NOT NULL DEFAULT 0,
    `defender_max_health` INT UNSIGNED NOT NULL DEFAULT 100000,
    -- NPC position (event starter)
    `npc_entry` INT UNSIGNED NOT NULL COMMENT 'NPC entry for event starter',
    `npc_x` FLOAT NOT NULL,
    `npc_y` FLOAT NOT NULL,
    `npc_z` FLOAT NOT NULL,
    `npc_o` FLOAT NOT NULL DEFAULT 0,
    -- Timing
    `preparation_time` INT UNSIGNED NOT NULL DEFAULT 30 COMMENT 'Seconds before first wave',
    `wave_interval` INT UNSIGNED NOT NULL DEFAULT 10 COMMENT 'Seconds between waves',
    `max_waves` TINYINT UNSIGNED NOT NULL DEFAULT 10,
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`arena_id`),
    INDEX `idx_map` (`map_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Tower defense arena definitions';

-- ============================================================================
-- SPAWN POINTS
-- Where mobs spawn for each arena
-- ============================================================================

DROP TABLE IF EXISTS `custom_tower_defense_spawn_points`;
CREATE TABLE `custom_tower_defense_spawn_points` (
    `spawn_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `arena_id` INT UNSIGNED NOT NULL,
    `spawn_group` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Group spawns together',
    `x` FLOAT NOT NULL,
    `y` FLOAT NOT NULL,
    `z` FLOAT NOT NULL,
    `o` FLOAT NOT NULL DEFAULT 0,
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`spawn_id`),
    INDEX `idx_arena` (`arena_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Mob spawn points for arenas';

-- ============================================================================
-- WAVE DEFINITIONS
-- Defines what spawns in each wave
-- ============================================================================

DROP TABLE IF EXISTS `custom_tower_defense_waves`;
CREATE TABLE `custom_tower_defense_waves` (
    `wave_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `arena_id` INT UNSIGNED NOT NULL,
    `wave_number` TINYINT UNSIGNED NOT NULL,
    `creature_entry` INT UNSIGNED NOT NULL COMMENT 'Creature template entry',
    `creature_count` TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `spawn_delay` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Delay in ms after wave starts',
    `spawn_group` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Which spawn points to use',
    `health_modifier` FLOAT NOT NULL DEFAULT 1.0 COMMENT 'Health multiplier',
    `damage_modifier` FLOAT NOT NULL DEFAULT 1.0 COMMENT 'Damage multiplier',
    `speed_modifier` FLOAT NOT NULL DEFAULT 1.0 COMMENT 'Movement speed multiplier',
    `is_boss` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Is this a boss mob',
    PRIMARY KEY (`wave_id`),
    INDEX `idx_arena_wave` (`arena_id`, `wave_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Wave mob definitions';

-- ============================================================================
-- WAVE REWARDS
-- Rewards for completing each wave
-- ============================================================================

DROP TABLE IF EXISTS `custom_tower_defense_rewards`;
CREATE TABLE `custom_tower_defense_rewards` (
    `reward_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `arena_id` INT UNSIGNED NOT NULL,
    `wave_number` TINYINT UNSIGNED NOT NULL COMMENT '0 = completion bonus',
    `reward_type` ENUM('item', 'money', 'honor', 'xp', 'title', 'achievement') NOT NULL,
    `reward_entry` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Item entry, title ID, etc.',
    `reward_count` INT UNSIGNED NOT NULL DEFAULT 1,
    `chance` FLOAT NOT NULL DEFAULT 100 COMMENT 'Drop chance percentage',
    `per_player` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Each player gets reward',
    `announce` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Announce to server',
    PRIMARY KEY (`reward_id`),
    INDEX `idx_arena_wave` (`arena_id`, `wave_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Wave completion rewards';

-- ============================================================================
-- PLAYER/GROUP PROGRESS
-- Track best wave reached
-- ============================================================================

DROP TABLE IF EXISTS `custom_tower_defense_progress`;
CREATE TABLE `custom_tower_defense_progress` (
    `guid` INT UNSIGNED NOT NULL,
    `arena_id` INT UNSIGNED NOT NULL,
    `best_wave` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `total_completions` INT UNSIGNED NOT NULL DEFAULT 0,
    `total_attempts` INT UNSIGNED NOT NULL DEFAULT 0,
    `fastest_time` INT UNSIGNED DEFAULT NULL COMMENT 'Fastest completion in seconds',
    `last_attempt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`guid`, `arena_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Player tower defense progress';

-- ============================================================================
-- ACTIVE EVENTS (runtime tracking)
-- ============================================================================

DROP TABLE IF EXISTS `custom_tower_defense_active`;
CREATE TABLE `custom_tower_defense_active` (
    `instance_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `arena_id` INT UNSIGNED NOT NULL,
    `leader_guid` INT UNSIGNED NOT NULL,
    `current_wave` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `defender_health` INT UNSIGNED NOT NULL,
    `start_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `status` ENUM('preparing', 'in_progress', 'wave_complete', 'completed', 'failed') NOT NULL DEFAULT 'preparing',
    PRIMARY KEY (`instance_id`),
    INDEX `idx_leader` (`leader_guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Active tower defense instances';

-- ============================================================================
-- EXAMPLE ARENA: Crossroads Defense
-- ============================================================================

INSERT INTO `custom_tower_defense_arenas`
(`arena_id`, `name`, `description`, `map_id`, `min_players`, `max_players`, `min_level`, `max_level`,
 `defender_entry`, `defender_is_creature`, `defender_x`, `defender_y`, `defender_z`, `defender_o`, `defender_max_health`,
 `npc_entry`, `npc_x`, `npc_y`, `npc_z`, `npc_o`,
 `preparation_time`, `wave_interval`, `max_waves`) VALUES
(1, 'Crossroads Defense', 'Defend the Crossroads watchtower from endless waves of centaurs!',
 1, 1, 5, 15, 25,
 -- Defender (watchtower or NPC)
 175080, 0, -456.0, -2652.0, 96.0, 0, 50000,
 -- Event NPC
 190001, -460.0, -2648.0, 96.0, 3.14,
 -- Timing
 30, 15, 10);

-- Spawn points around the arena
INSERT INTO `custom_tower_defense_spawn_points`
(`arena_id`, `spawn_group`, `x`, `y`, `z`, `o`) VALUES
-- North spawns (group 0)
(1, 0, -456.0, -2600.0, 96.0, 4.7),
(1, 0, -446.0, -2605.0, 96.0, 4.5),
(1, 0, -466.0, -2605.0, 96.0, 4.9),
-- South spawns (group 1)
(1, 1, -456.0, -2700.0, 96.0, 1.5),
(1, 1, -446.0, -2695.0, 96.0, 1.7),
(1, 1, -466.0, -2695.0, 96.0, 1.3),
-- East spawns (group 2)
(1, 2, -406.0, -2652.0, 96.0, 3.14),
(1, 2, -410.0, -2642.0, 96.0, 3.3),
-- West spawns (group 3)
(1, 3, -506.0, -2652.0, 96.0, 0),
(1, 3, -502.0, -2662.0, 96.0, 0.2);

-- Wave definitions (using placeholder creature entries - replace with actual)
-- Wave 1: Easy - few weak mobs
INSERT INTO `custom_tower_defense_waves`
(`arena_id`, `wave_number`, `creature_entry`, `creature_count`, `spawn_delay`, `spawn_group`,
 `health_modifier`, `damage_modifier`, `speed_modifier`, `is_boss`) VALUES
(1, 1, 3272, 3, 0, 0, 0.8, 0.8, 1.0, 0),     -- 3 centaurs from north
(1, 1, 3272, 2, 2000, 1, 0.8, 0.8, 1.0, 0);   -- 2 more from south after 2s

-- Wave 2: More mobs
INSERT INTO `custom_tower_defense_waves`
(`arena_id`, `wave_number`, `creature_entry`, `creature_count`, `spawn_delay`, `spawn_group`,
 `health_modifier`, `damage_modifier`, `speed_modifier`, `is_boss`) VALUES
(1, 2, 3272, 4, 0, 0, 0.9, 0.9, 1.0, 0),
(1, 2, 3272, 3, 2000, 1, 0.9, 0.9, 1.0, 0),
(1, 2, 3273, 2, 4000, 2, 1.0, 1.0, 1.0, 0);   -- Stronger mob type

-- Wave 3: Three directions
INSERT INTO `custom_tower_defense_waves`
(`arena_id`, `wave_number`, `creature_entry`, `creature_count`, `spawn_delay`, `spawn_group`,
 `health_modifier`, `damage_modifier`, `speed_modifier`, `is_boss`) VALUES
(1, 3, 3272, 4, 0, 0, 1.0, 1.0, 1.0, 0),
(1, 3, 3272, 4, 0, 1, 1.0, 1.0, 1.0, 0),
(1, 3, 3273, 3, 3000, 2, 1.0, 1.0, 1.0, 0);

-- Wave 4: Faster mobs
INSERT INTO `custom_tower_defense_waves`
(`arena_id`, `wave_number`, `creature_entry`, `creature_count`, `spawn_delay`, `spawn_group`,
 `health_modifier`, `damage_modifier`, `speed_modifier`, `is_boss`) VALUES
(1, 4, 3272, 5, 0, 0, 1.0, 1.0, 1.3, 0),
(1, 4, 3272, 5, 0, 1, 1.0, 1.0, 1.3, 0),
(1, 4, 3273, 3, 2000, 2, 1.1, 1.1, 1.2, 0),
(1, 4, 3273, 3, 2000, 3, 1.1, 1.1, 1.2, 0);

-- Wave 5: Mini-boss wave
INSERT INTO `custom_tower_defense_waves`
(`arena_id`, `wave_number`, `creature_entry`, `creature_count`, `spawn_delay`, `spawn_group`,
 `health_modifier`, `damage_modifier`, `speed_modifier`, `is_boss`) VALUES
(1, 5, 3272, 6, 0, 0, 1.0, 1.0, 1.0, 0),
(1, 5, 3272, 6, 0, 1, 1.0, 1.0, 1.0, 0),
(1, 5, 3274, 1, 5000, 0, 3.0, 2.0, 0.8, 1);   -- Mini-boss

-- Wave 6-9: Escalating difficulty
INSERT INTO `custom_tower_defense_waves`
(`arena_id`, `wave_number`, `creature_entry`, `creature_count`, `spawn_delay`, `spawn_group`,
 `health_modifier`, `damage_modifier`, `speed_modifier`, `is_boss`) VALUES
(1, 6, 3273, 6, 0, 0, 1.2, 1.2, 1.0, 0),
(1, 6, 3273, 6, 0, 1, 1.2, 1.2, 1.0, 0),
(1, 6, 3273, 4, 3000, 2, 1.2, 1.2, 1.0, 0),
(1, 6, 3273, 4, 3000, 3, 1.2, 1.2, 1.0, 0);

INSERT INTO `custom_tower_defense_waves`
(`arena_id`, `wave_number`, `creature_entry`, `creature_count`, `spawn_delay`, `spawn_group`,
 `health_modifier`, `damage_modifier`, `speed_modifier`, `is_boss`) VALUES
(1, 7, 3273, 8, 0, 0, 1.3, 1.3, 1.1, 0),
(1, 7, 3273, 8, 0, 1, 1.3, 1.3, 1.1, 0),
(1, 7, 3274, 2, 4000, 2, 2.0, 1.5, 1.0, 0),
(1, 7, 3274, 2, 4000, 3, 2.0, 1.5, 1.0, 0);

INSERT INTO `custom_tower_defense_waves`
(`arena_id`, `wave_number`, `creature_entry`, `creature_count`, `spawn_delay`, `spawn_group`,
 `health_modifier`, `damage_modifier`, `speed_modifier`, `is_boss`) VALUES
(1, 8, 3273, 10, 0, 0, 1.4, 1.4, 1.2, 0),
(1, 8, 3273, 10, 0, 1, 1.4, 1.4, 1.2, 0),
(1, 8, 3274, 3, 3000, 2, 2.5, 1.8, 1.0, 0),
(1, 8, 3274, 3, 3000, 3, 2.5, 1.8, 1.0, 0);

INSERT INTO `custom_tower_defense_waves`
(`arena_id`, `wave_number`, `creature_entry`, `creature_count`, `spawn_delay`, `spawn_group`,
 `health_modifier`, `damage_modifier`, `speed_modifier`, `is_boss`) VALUES
(1, 9, 3273, 8, 0, 0, 1.5, 1.5, 1.0, 0),
(1, 9, 3273, 8, 0, 1, 1.5, 1.5, 1.0, 0),
(1, 9, 3273, 8, 0, 2, 1.5, 1.5, 1.0, 0),
(1, 9, 3273, 8, 0, 3, 1.5, 1.5, 1.0, 0),
(1, 9, 3274, 1, 5000, 0, 4.0, 2.5, 0.9, 1);

-- Wave 10: Final boss wave
INSERT INTO `custom_tower_defense_waves`
(`arena_id`, `wave_number`, `creature_entry`, `creature_count`, `spawn_delay`, `spawn_group`,
 `health_modifier`, `damage_modifier`, `speed_modifier`, `is_boss`) VALUES
(1, 10, 3273, 5, 0, 0, 1.5, 1.5, 1.0, 0),
(1, 10, 3273, 5, 0, 1, 1.5, 1.5, 1.0, 0),
(1, 10, 3273, 5, 0, 2, 1.5, 1.5, 1.0, 0),
(1, 10, 3273, 5, 0, 3, 1.5, 1.5, 1.0, 0),
(1, 10, 3275, 1, 8000, 0, 10.0, 3.0, 0.7, 1);  -- Final boss

-- ============================================================================
-- REWARDS
-- ============================================================================

-- Per-wave rewards (money scales with wave)
INSERT INTO `custom_tower_defense_rewards`
(`arena_id`, `wave_number`, `reward_type`, `reward_entry`, `reward_count`, `chance`, `per_player`) VALUES
(1, 1, 'money', 0, 1000, 100, 1),      -- 10 silver
(1, 2, 'money', 0, 2000, 100, 1),      -- 20 silver
(1, 3, 'money', 0, 3000, 100, 1),
(1, 4, 'money', 0, 5000, 100, 1),
(1, 5, 'money', 0, 10000, 100, 1),     -- 1 gold (mini-boss)
(1, 6, 'money', 0, 8000, 100, 1),
(1, 7, 'money', 0, 10000, 100, 1),
(1, 8, 'money', 0, 15000, 100, 1),
(1, 9, 'money', 0, 20000, 100, 1),
(1, 10, 'money', 0, 50000, 100, 1);    -- 5 gold (final boss)

-- XP rewards
INSERT INTO `custom_tower_defense_rewards`
(`arena_id`, `wave_number`, `reward_type`, `reward_entry`, `reward_count`, `chance`, `per_player`) VALUES
(1, 5, 'xp', 0, 500, 100, 1),          -- Mini-boss XP
(1, 10, 'xp', 0, 2000, 100, 1);        -- Final boss XP

-- Item rewards (chance-based)
INSERT INTO `custom_tower_defense_rewards`
(`arena_id`, `wave_number`, `reward_type`, `reward_entry`, `reward_count`, `chance`, `per_player`, `announce`) VALUES
(1, 5, 'item', 2589, 5, 50, 1, 0),     -- 50% chance for 5x Linen Cloth
(1, 10, 'item', 2592, 10, 100, 1, 0),  -- 100% chance for 10x Wool Cloth
(1, 0, 'item', 7005, 1, 10, 1, 1);     -- 10% chance for rare item on completion

-- Completion bonus (wave 0 = full completion)
INSERT INTO `custom_tower_defense_rewards`
(`arena_id`, `wave_number`, `reward_type`, `reward_entry`, `reward_count`, `chance`, `per_player`, `announce`) VALUES
(1, 0, 'money', 0, 100000, 100, 1, 0), -- 10 gold completion bonus
(1, 0, 'xp', 0, 5000, 100, 1, 0);      -- Big XP bonus

-- ============================================================================
-- NPC TEMPLATE (add this to creature_template or use existing NPC)
-- ============================================================================

-- INSERT INTO creature_template
-- (entry, name, subname, minlevel, maxlevel, faction, npcflag, unit_flags, type, ScriptName) VALUES
-- (190001, 'Tower Defense Master', 'Event Coordinator', 60, 60, 35, 1, 2, 7, 'npc_tower_defense');

-- ============================================================================
-- HELPFUL QUERIES
-- ============================================================================

-- View arena details:
-- SELECT * FROM custom_tower_defense_arenas;

-- View waves for an arena:
-- SELECT * FROM custom_tower_defense_waves WHERE arena_id = 1 ORDER BY wave_number, spawn_delay;

-- View player progress:
-- SELECT p.*, a.name as arena_name FROM custom_tower_defense_progress p
-- JOIN custom_tower_defense_arenas a ON p.arena_id = a.arena_id
-- ORDER BY best_wave DESC;

-- ============================================================================
