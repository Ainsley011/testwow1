-- ============================================================================
-- ARTIFACT WEAPON SYSTEM
-- Custom weapons with progression, special abilities, and database-driven stats
-- ============================================================================

-- ============================================================================
-- ARTIFACT WEAPON DEFINITIONS TABLE
-- Define your custom artifact weapons here
-- ============================================================================

DROP TABLE IF EXISTS `custom_artifact_weapons`;
CREATE TABLE `custom_artifact_weapons` (
    `entry` INT UNSIGNED NOT NULL COMMENT 'Item entry ID (must match item_template)',
    `name` VARCHAR(100) NOT NULL COMMENT 'Weapon name for reference',
    `description` TEXT COMMENT 'Lore/description of the artifact',
    `max_tier` TINYINT UNSIGNED NOT NULL DEFAULT 10 COMMENT 'Maximum upgrade tier',
    `exp_per_kill` INT UNSIGNED NOT NULL DEFAULT 100 COMMENT 'Base EXP gained per kill',
    `exp_per_boss` INT UNSIGNED NOT NULL DEFAULT 1000 COMMENT 'EXP gained per boss kill',
    `exp_per_quest` INT UNSIGNED NOT NULL DEFAULT 500 COMMENT 'EXP gained per quest complete',
    `allow_pvp_exp` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Allow EXP from PvP kills',
    `exp_pvp_kill` INT UNSIGNED NOT NULL DEFAULT 50 COMMENT 'EXP from PvP kill if enabled',
    `class_mask` INT NOT NULL DEFAULT -1 COMMENT 'Allowed classes (-1 = all)',
    `race_mask` INT NOT NULL DEFAULT -1 COMMENT 'Allowed races (-1 = all)',
    `min_level` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Minimum player level',
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Artifact weapon base definitions';

-- ============================================================================
-- ARTIFACT WEAPON TIERS TABLE
-- Define stats/bonuses for each tier of the artifact
-- ============================================================================

DROP TABLE IF EXISTS `custom_artifact_weapon_tiers`;
CREATE TABLE `custom_artifact_weapon_tiers` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `weapon_entry` INT UNSIGNED NOT NULL COMMENT 'Reference to custom_artifact_weapons.entry',
    `tier` TINYINT UNSIGNED NOT NULL COMMENT 'Tier level (0 = base)',
    `exp_required` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'EXP required for this tier',
    `stat_type_1` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Stat type (see ItemMod enum)',
    `stat_value_1` INT NOT NULL DEFAULT 0 COMMENT 'Stat value',
    `stat_type_2` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `stat_value_2` INT NOT NULL DEFAULT 0,
    `stat_type_3` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `stat_value_3` INT NOT NULL DEFAULT 0,
    `stat_type_4` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `stat_value_4` INT NOT NULL DEFAULT 0,
    `stat_type_5` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `stat_value_5` INT NOT NULL DEFAULT 0,
    `damage_min` FLOAT NOT NULL DEFAULT 0 COMMENT 'Bonus min damage',
    `damage_max` FLOAT NOT NULL DEFAULT 0 COMMENT 'Bonus max damage',
    `armor` INT NOT NULL DEFAULT 0 COMMENT 'Bonus armor',
    `spell_id` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Spell granted at this tier',
    `proc_spell_id` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Proc spell at this tier',
    `proc_chance` FLOAT NOT NULL DEFAULT 0 COMMENT 'Proc chance %',
    `name_suffix` VARCHAR(50) DEFAULT NULL COMMENT 'Name suffix at this tier (e.g., "of Power")',
    `visual_effect` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Visual enchant ID',
    `announce_on_unlock` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Server announce when unlocked',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_weapon_tier` (`weapon_entry`, `tier`),
    INDEX `idx_weapon` (`weapon_entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Artifact weapon tier progression';

-- ============================================================================
-- ARTIFACT WEAPON ABILITIES TABLE
-- Special abilities that unlock at certain tiers
-- ============================================================================

DROP TABLE IF EXISTS `custom_artifact_weapon_abilities`;
CREATE TABLE `custom_artifact_weapon_abilities` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `weapon_entry` INT UNSIGNED NOT NULL COMMENT 'Reference to artifact weapon',
    `tier_required` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Tier required to unlock',
    `ability_type` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '0=Passive, 1=Active (use spell), 2=Proc',
    `spell_id` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Spell ID for the ability',
    `name` VARCHAR(100) NOT NULL COMMENT 'Ability name',
    `description` VARCHAR(255) DEFAULT NULL COMMENT 'Ability description',
    `proc_trigger` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Proc trigger type (0=hit, 1=crit, 2=kill, 3=damaged)',
    `proc_chance` FLOAT NOT NULL DEFAULT 100 COMMENT 'Proc chance %',
    `cooldown` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Cooldown in seconds',
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`),
    INDEX `idx_weapon` (`weapon_entry`),
    INDEX `idx_tier` (`tier_required`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Artifact weapon special abilities';

-- ============================================================================
-- PLAYER ARTIFACT PROGRESS TABLE
-- Track player progression with their artifact weapons
-- ============================================================================

DROP TABLE IF EXISTS `character_artifact_weapon`;
CREATE TABLE `character_artifact_weapon` (
    `guid` INT UNSIGNED NOT NULL COMMENT 'Character GUID',
    `item_guid` INT UNSIGNED NOT NULL COMMENT 'Item instance GUID',
    `weapon_entry` INT UNSIGNED NOT NULL COMMENT 'Artifact weapon entry',
    `current_tier` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `current_exp` INT UNSIGNED NOT NULL DEFAULT 0,
    `total_exp` INT UNSIGNED NOT NULL DEFAULT 0,
    `kills` INT UNSIGNED NOT NULL DEFAULT 0,
    `boss_kills` INT UNSIGNED NOT NULL DEFAULT 0,
    `pvp_kills` INT UNSIGNED NOT NULL DEFAULT 0,
    `quests_completed` INT UNSIGNED NOT NULL DEFAULT 0,
    `last_updated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`guid`, `item_guid`),
    INDEX `idx_weapon_entry` (`weapon_entry`),
    INDEX `idx_tier` (`current_tier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Player artifact weapon progress';

-- ============================================================================
-- STAT TYPE REFERENCE (ItemMod enum values):
-- 0  = MANA
-- 1  = HEALTH
-- 3  = AGILITY
-- 4  = STRENGTH
-- 5  = INTELLECT
-- 6  = SPIRIT
-- 7  = STAMINA
-- 12 = DEFENSE_SKILL_RATING
-- 13 = DODGE_RATING
-- 14 = PARRY_RATING
-- 15 = BLOCK_RATING
-- 16 = HIT_MELEE_RATING
-- 17 = HIT_RANGED_RATING
-- 18 = HIT_SPELL_RATING
-- 19 = CRIT_MELEE_RATING
-- 20 = CRIT_RANGED_RATING
-- 21 = CRIT_SPELL_RATING
-- 28 = HASTE_MELEE_RATING
-- 29 = HASTE_RANGED_RATING
-- 30 = HASTE_SPELL_RATING
-- 31 = HIT_RATING
-- 32 = CRIT_RATING
-- 36 = HASTE_RATING
-- 38 = ATTACK_POWER
-- 41 = SPELL_POWER
-- 43 = ARMOR_PENETRATION_RATING
-- 44 = SPELL_PENETRATION
-- 45 = BLOCK_VALUE
-- ============================================================================

-- ============================================================================
-- EXAMPLE ARTIFACT WEAPONS
-- ============================================================================

-- Example: Shadowmourne Reborn (2H Sword for Warriors/Paladins/Death Knights)
INSERT INTO `custom_artifact_weapons` (`entry`, `name`, `description`, `max_tier`, `exp_per_kill`, `exp_per_boss`, `exp_per_quest`, `class_mask`, `min_level`, `enabled`) VALUES
(100001, 'Shadowmourne Reborn', 'A legendary blade reforged from the shards of Frostmourne. It hungers for souls.', 10, 50, 500, 250, 1|2|32, 80, 1);

-- Tier progression for Shadowmourne Reborn
INSERT INTO `custom_artifact_weapon_tiers` (`weapon_entry`, `tier`, `exp_required`, `stat_type_1`, `stat_value_1`, `stat_type_2`, `stat_value_2`, `stat_type_3`, `stat_value_3`, `damage_min`, `damage_max`, `name_suffix`, `visual_effect`, `announce_on_unlock`) VALUES
(100001, 0, 0,       4, 50,  7, 40, 32, 20,  0, 0,     NULL, 0, 0),           -- Base: 50 Str, 40 Stam, 20 Crit
(100001, 1, 1000,    4, 60,  7, 50, 32, 30,  5, 10,    'of Awakening', 0, 0),
(100001, 2, 3000,    4, 75,  7, 60, 32, 40,  10, 20,   'of Power', 0, 0),
(100001, 3, 6000,    4, 90,  7, 75, 32, 50,  15, 30,   'of Might', 0, 0),
(100001, 4, 10000,   4, 110, 7, 90, 32, 65,  25, 50,   'of Conquest', 3789, 0),
(100001, 5, 15000,   4, 130, 7, 110, 32, 80, 40, 80,   'of Domination', 3789, 1), -- Announce tier 5
(100001, 6, 22000,   4, 155, 7, 130, 32, 100, 60, 120, 'of Devastation', 3789, 0),
(100001, 7, 30000,   4, 180, 7, 155, 32, 120, 85, 170, 'of Annihilation', 3789, 0),
(100001, 8, 40000,   4, 210, 7, 180, 32, 145, 115, 230, 'of Oblivion', 3825, 0),
(100001, 9, 55000,   4, 250, 7, 210, 32, 175, 150, 300, 'of the Damned', 3825, 1),
(100001, 10, 75000,  4, 300, 7, 250, 32, 200, 200, 400, ', Soul Reaper', 3825, 1); -- Final tier

-- Abilities for Shadowmourne Reborn
INSERT INTO `custom_artifact_weapon_abilities` (`weapon_entry`, `tier_required`, `ability_type`, `spell_id`, `name`, `description`, `proc_trigger`, `proc_chance`, `cooldown`) VALUES
(100001, 3, 2, 0, 'Soul Fragment', 'Attacks have a chance to absorb a fragment of the target''s soul, healing the wielder.', 0, 10, 0),
(100001, 5, 2, 0, 'Chaos Bane', 'Killing an enemy grants a stacking buff that increases damage.', 2, 100, 0),
(100001, 7, 1, 0, 'Unleash Souls', 'Release absorbed souls to deal massive shadow damage to all nearby enemies.', 0, 100, 120),
(100001, 10, 0, 0, 'Soul Reaper''s Blessing', 'Permanently increases all stats by 5% while wielding this weapon.', 0, 100, 0);

-- Example: Dragonwrath Reforged (Staff for Casters)
INSERT INTO `custom_artifact_weapons` (`entry`, `name`, `description`, `max_tier`, `exp_per_kill`, `exp_per_boss`, `exp_per_quest`, `class_mask`, `min_level`, `enabled`) VALUES
(100002, 'Dragonwrath Reforged', 'A staff imbued with the essence of the Blue Dragonflight. It crackles with arcane energy.', 10, 50, 500, 250, 16|64|128|256, 80, 1);

-- Tier progression for Dragonwrath Reforged
INSERT INTO `custom_artifact_weapon_tiers` (`weapon_entry`, `tier`, `exp_required`, `stat_type_1`, `stat_value_1`, `stat_type_2`, `stat_value_2`, `stat_type_3`, `stat_value_3`, `stat_type_4`, `stat_value_4`, `name_suffix`, `visual_effect`) VALUES
(100002, 0, 0,       5, 50,  7, 40, 41, 100, 36, 30,   NULL, 0),
(100002, 1, 1000,    5, 60,  7, 50, 41, 130, 36, 40,   'of the Initiate', 0),
(100002, 2, 3000,    5, 75,  7, 60, 41, 170, 36, 55,   'of the Apprentice', 0),
(100002, 3, 6000,    5, 90,  7, 75, 41, 220, 36, 70,   'of the Adept', 0),
(100002, 4, 10000,   5, 110, 7, 90, 41, 280, 36, 90,   'of the Mage', 3846),
(100002, 5, 15000,   5, 130, 7, 110, 41, 350, 36, 115, 'of the Archmage', 3846),
(100002, 6, 22000,   5, 155, 7, 130, 41, 430, 36, 140, 'of Brilliance', 3846),
(100002, 7, 30000,   5, 180, 7, 155, 41, 520, 36, 170, 'of Ascendance', 3846),
(100002, 8, 40000,   5, 210, 7, 180, 41, 620, 36, 200, 'of the Blue Flight', 3870),
(100002, 9, 55000,   5, 250, 7, 210, 41, 740, 36, 235, 'of Tarecgosa', 3870),
(100002, 10, 75000,  5, 300, 7, 250, 41, 900, 36, 275, ', Dragonlord''s Legacy', 3870);

-- ============================================================================
-- SAMPLE ITEM TEMPLATE (needs to be added to item_template)
-- Run this to create the base items
-- ============================================================================

-- Shadowmourne Reborn (2H Sword)
DELETE FROM `item_template` WHERE `entry` = 100001;
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `Flags`, `BuyPrice`, `SellPrice`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `dmg_min1`, `dmg_max1`, `dmg_type1`, `delay`, `bonding`, `description`, `ScriptName`) VALUES
(100001, 2, 8, 'Shadowmourne Reborn', 51020, 5, 0, 0, 0, 17, 1|2|32, -1, 284, 80, 550, 826, 0, 3600, 1, 'A legendary blade reforged. It grows stronger with each soul it claims.', 'item_artifact_weapon');

-- Dragonwrath Reforged (Staff)
DELETE FROM `item_template` WHERE `entry` = 100002;
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `Flags`, `BuyPrice`, `SellPrice`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `dmg_min1`, `dmg_max1`, `dmg_type1`, `delay`, `bonding`, `description`, `ScriptName`) VALUES
(100002, 2, 10, 'Dragonwrath Reforged', 64561, 5, 0, 0, 0, 17, 16|64|128|256, -1, 284, 80, 200, 370, 0, 2500, 1, 'A staff of immense arcane power. It evolves with its wielder.', 'item_artifact_weapon');

-- ============================================================================
-- HELPFUL QUERIES
-- ============================================================================

-- Add a new artifact weapon:
-- 1. Add to item_template with ScriptName='item_artifact_weapon'
-- 2. Add to custom_artifact_weapons
-- 3. Add tier progression to custom_artifact_weapon_tiers
-- 4. Optionally add abilities to custom_artifact_weapon_abilities

-- Check player progress:
-- SELECT * FROM character_artifact_weapon WHERE guid = <player_guid>;

-- Reset player artifact progress:
-- DELETE FROM character_artifact_weapon WHERE guid = <player_guid> AND weapon_entry = <weapon_entry>;

-- View all artifacts and their current tier distribution:
-- SELECT weapon_entry, current_tier, COUNT(*) as players
-- FROM character_artifact_weapon
-- GROUP BY weapon_entry, current_tier
-- ORDER BY weapon_entry, current_tier;
