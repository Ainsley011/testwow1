-- =====================================================
-- Custom Systems SQL - Transmog, Mythic+, Titles,
-- Staff Log, Server Stats, Changelog, Talent Prestige
-- =====================================================

-- =====================================================
-- TRANSMOG SYSTEM
-- =====================================================

-- Transmog settings (World database)
DROP TABLE IF EXISTS `custom_transmog_settings`;
CREATE TABLE `custom_transmog_settings` (
    `setting_name` VARCHAR(50) NOT NULL,
    `setting_value` INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`setting_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `custom_transmog_settings` VALUES
('gold_cost', 100000),           -- 10 gold per transmog
('token_cost', 0),               -- No token cost by default
('token_item_id', 0),            -- Token item ID if used
('require_same_armor_type', 1),  -- Require matching armor type
('allow_legendaries', 0);        -- Don't allow legendary transmog

-- Character transmog data (Character database)
-- Run this on CHARACTER database
/*
DROP TABLE IF EXISTS `character_transmog`;
CREATE TABLE `character_transmog` (
    `guid` INT UNSIGNED NOT NULL,
    `slot` TINYINT UNSIGNED NOT NULL,
    `display_id` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`guid`, `slot`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
*/

-- =====================================================
-- MYTHIC+ DUNGEON SYSTEM
-- =====================================================

-- Mythic+ dungeons (World database)
DROP TABLE IF EXISTS `custom_mythic_dungeons`;
CREATE TABLE `custom_mythic_dungeons` (
    `dungeon_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `map_id` INT UNSIGNED NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `timer_minutes` INT UNSIGNED NOT NULL DEFAULT 30,
    `enemy_forces` INT UNSIGNED NOT NULL DEFAULT 100,
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`dungeon_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Sample dungeons
INSERT INTO `custom_mythic_dungeons` (`map_id`, `name`, `timer_minutes`, `enemy_forces`, `enabled`) VALUES
(576, 'The Nexus', 25, 100, 1),
(601, 'Azjol-Nerub', 20, 80, 1),
(619, 'Ahn''kahet: The Old Kingdom', 30, 120, 1),
(604, 'Gundrak', 25, 100, 1),
(608, 'Violet Hold', 20, 60, 1),
(658, 'Pit of Saron', 30, 100, 1),
(632, 'The Forge of Souls', 25, 80, 1),
(668, 'Halls of Reflection', 25, 80, 1);

-- Affix rotation (World database)
DROP TABLE IF EXISTS `custom_mythic_affix_rotation`;
CREATE TABLE `custom_mythic_affix_rotation` (
    `week_number` INT UNSIGNED NOT NULL,
    `affix1` TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `affix2` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `affix3` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`week_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 12-week rotation
INSERT INTO `custom_mythic_affix_rotation` VALUES
(0, 1, 3, 9),   -- Fortified, Bolstering, Quaking
(1, 2, 4, 10),  -- Tyrannical, Raging, Volcanic
(2, 1, 5, 11),  -- Fortified, Sanguine, Grievous
(3, 2, 6, 9),   -- Tyrannical, Bursting, Quaking
(4, 1, 7, 10),  -- Fortified, Necrotic, Volcanic
(5, 2, 8, 11),  -- Tyrannical, Explosive, Grievous
(6, 1, 3, 10),  -- Fortified, Bolstering, Volcanic
(7, 2, 4, 9),   -- Tyrannical, Raging, Quaking
(8, 1, 5, 10),  -- Fortified, Sanguine, Volcanic
(9, 2, 6, 11),  -- Tyrannical, Bursting, Grievous
(10, 1, 7, 9),  -- Fortified, Necrotic, Quaking
(11, 2, 8, 10); -- Tyrannical, Explosive, Volcanic

-- Character keystones (Character database)
/*
DROP TABLE IF EXISTS `character_mythic_keystone`;
CREATE TABLE `character_mythic_keystone` (
    `guid` INT UNSIGNED NOT NULL,
    `dungeon_id` INT UNSIGNED NOT NULL,
    `level` TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `affix1` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `affix2` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `affix3` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `depleted` TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `custom_mythic_leaderboard`;
CREATE TABLE `custom_mythic_leaderboard` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `dungeon_id` INT UNSIGNED NOT NULL,
    `level` TINYINT UNSIGNED NOT NULL,
    `time_ms` INT UNSIGNED NOT NULL,
    `player_names` VARCHAR(255) NOT NULL,
    `completion_date` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_dungeon_level` (`dungeon_id`, `level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
*/

-- =====================================================
-- CUSTOM TITLES SYSTEM (5-25% stat bonus)
-- =====================================================

-- Custom titles (World database)
DROP TABLE IF EXISTS `custom_titles`;
CREATE TABLE `custom_titles` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `prefix` VARCHAR(50) NOT NULL DEFAULT '',
    `suffix` VARCHAR(50) NOT NULL DEFAULT '',
    `stat_bonus` TINYINT UNSIGNED NOT NULL DEFAULT 5,
    `gold_cost` INT UNSIGNED NOT NULL DEFAULT 0,
    `donation_cost` INT UNSIGNED NOT NULL DEFAULT 0,
    `vote_cost` INT UNSIGNED NOT NULL DEFAULT 0,
    `achievement_id` INT UNSIGNED NOT NULL DEFAULT 0,
    `required_kills` INT UNSIGNED NOT NULL DEFAULT 0,
    `required_level` TINYINT UNSIGNED NOT NULL DEFAULT 80,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Sample titles with varying stat bonuses
INSERT INTO `custom_titles` (`name`, `prefix`, `suffix`, `stat_bonus`, `gold_cost`, `donation_cost`, `vote_cost`, `required_kills`, `required_level`) VALUES
-- 5% stat bonus titles (cheap/easy)
('Adventurer', '', 'the Adventurer', 5, 500000, 0, 0, 0, 80),
('Explorer', '', 'the Explorer', 5, 500000, 0, 0, 0, 80),
('Traveler', '', 'the Traveler', 5, 0, 0, 50, 0, 80),

-- 10% stat bonus titles (moderate)
('Veteran', '', 'the Veteran', 10, 2000000, 0, 0, 1000, 80),
('Gladiator', 'Gladiator', '', 10, 0, 0, 100, 5000, 80),
('Battlemaster', '', 'the Battlemaster', 10, 5000000, 0, 0, 2500, 80),

-- 15% stat bonus titles (expensive)
('Champion', 'Champion', '', 15, 10000000, 0, 0, 0, 80),
('Warlord', 'Warlord', '', 15, 0, 50, 0, 10000, 80),
('Conqueror', '', 'the Conqueror', 15, 0, 0, 200, 0, 80),

-- 20% stat bonus titles (very expensive)
('Legend', '', 'the Legend', 20, 50000000, 0, 0, 0, 80),
('Immortal', '', 'the Immortal', 20, 0, 100, 0, 0, 80),
('Godslayer', '', 'Godslayer', 20, 0, 0, 500, 25000, 80),

-- 25% stat bonus titles (ultimate)
('Ascendant', 'Ascendant', '', 25, 0, 200, 0, 0, 80),
('Eternal', '', 'the Eternal', 25, 0, 150, 250, 50000, 80),
('Transcendent', '', 'the Transcendent', 25, 100000000, 0, 0, 0, 80);

-- Title buff spells (World database - spell_dbc)
DELETE FROM `spell_dbc` WHERE `Id` BETWEEN 900010 AND 900014;
INSERT INTO `spell_dbc` (`Id`, `Dispel`, `Mechanic`, `Attributes`, `AttributesEx`, `AttributesEx2`, `AttributesEx3`, `AttributesEx4`, `AttributesEx5`, `AttributesEx6`, `AttributesEx7`, `Stances`, `StancesNot`, `Targets`, `CastingTimeIndex`, `AuraInterruptFlags`, `ProcFlags`, `ProcChance`, `ProcCharges`, `MaxLevel`, `BaseLevel`, `SpellLevel`, `DurationIndex`, `RangeIndex`, `StackAmount`, `EquippedItemClass`, `EquippedItemSubClassMask`, `EquippedItemInventoryTypeMask`, `Effect1`, `Effect2`, `Effect3`, `EffectDieSides1`, `EffectDieSides2`, `EffectDieSides3`, `EffectRealPointsPerLevel1`, `EffectRealPointsPerLevel2`, `EffectRealPointsPerLevel3`, `EffectBasePoints1`, `EffectBasePoints2`, `EffectBasePoints3`, `EffectMechanic1`, `EffectMechanic2`, `EffectMechanic3`, `EffectImplicitTargetA1`, `EffectImplicitTargetA2`, `EffectImplicitTargetA3`, `EffectImplicitTargetB1`, `EffectImplicitTargetB2`, `EffectImplicitTargetB3`, `EffectRadiusIndex1`, `EffectRadiusIndex2`, `EffectRadiusIndex3`, `EffectApplyAuraName1`, `EffectApplyAuraName2`, `EffectApplyAuraName3`, `EffectAmplitude1`, `EffectAmplitude2`, `EffectAmplitude3`, `EffectMultipleValue1`, `EffectMultipleValue2`, `EffectMultipleValue3`, `EffectItemType1`, `EffectItemType2`, `EffectItemType3`, `EffectMiscValue1`, `EffectMiscValue2`, `EffectMiscValue3`, `EffectMiscValueB1`, `EffectMiscValueB2`, `EffectMiscValueB3`, `EffectTriggerSpell1`, `EffectTriggerSpell2`, `EffectTriggerSpell3`, `EffectSpellClassMaskA1`, `EffectSpellClassMaskA2`, `EffectSpellClassMaskA3`, `EffectSpellClassMaskB1`, `EffectSpellClassMaskB2`, `EffectSpellClassMaskB3`, `EffectSpellClassMaskC1`, `EffectSpellClassMaskC2`, `EffectSpellClassMaskC3`, `MaxTargetLevel`, `SpellFamilyName`, `SpellFamilyFlags1`, `SpellFamilyFlags2`, `SpellFamilyFlags3`, `MaxAffectedTargets`, `DmgClass`, `PreventionType`, `DmgMultiplier1`, `DmgMultiplier2`, `DmgMultiplier3`, `AreaGroupId`, `SchoolMask`, `Comment`) VALUES
(900010, 0, 0, 336, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 101, 0, 0, 0, 0, 21, 1, 0, -1, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 137, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 'Title Buff - 5% All Stats'),
(900011, 0, 0, 336, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 101, 0, 0, 0, 0, 21, 1, 0, -1, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 137, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 'Title Buff - 10% All Stats'),
(900012, 0, 0, 336, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 101, 0, 0, 0, 0, 21, 1, 0, -1, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 14, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 137, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 'Title Buff - 15% All Stats'),
(900013, 0, 0, 336, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 101, 0, 0, 0, 0, 21, 1, 0, -1, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 137, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 'Title Buff - 20% All Stats'),
(900014, 0, 0, 336, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 101, 0, 0, 0, 0, 21, 1, 0, -1, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 137, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 'Title Buff - 25% All Stats');

-- Character titles (Character database)
/*
DROP TABLE IF EXISTS `character_custom_titles`;
CREATE TABLE `character_custom_titles` (
    `guid` INT UNSIGNED NOT NULL,
    `title_id` INT UNSIGNED NOT NULL,
    `acquired_date` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`guid`, `title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `character_custom_title_active`;
CREATE TABLE `character_custom_title_active` (
    `guid` INT UNSIGNED NOT NULL,
    `title_id` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
*/

-- =====================================================
-- STAFF ACTIVITY LOG
-- =====================================================

-- Staff log settings (World database)
DROP TABLE IF EXISTS `custom_staff_log_settings`;
CREATE TABLE `custom_staff_log_settings` (
    `setting_name` VARCHAR(50) NOT NULL,
    `setting_value` INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`setting_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `custom_staff_log_settings` VALUES
('enabled', 1),
('log_lookups', 0),      -- Don't log lookup commands by default
('min_security_level', 1); -- Log GM level 1+

-- Staff activity log (Character database)
/*
DROP TABLE IF EXISTS `custom_staff_activity_log`;
CREATE TABLE `custom_staff_activity_log` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `account_id` INT UNSIGNED NOT NULL,
    `account_name` VARCHAR(50) NOT NULL,
    `character_guid` INT UNSIGNED NOT NULL,
    `character_name` VARCHAR(50) NOT NULL,
    `security_level` TINYINT UNSIGNED NOT NULL,
    `command` TEXT NOT NULL,
    `category` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `target_info` VARCHAR(255) NOT NULL DEFAULT '',
    `timestamp` INT UNSIGNED NOT NULL,
    `ip_address` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_account` (`account_id`),
    INDEX `idx_timestamp` (`timestamp`),
    INDEX `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
*/

-- =====================================================
-- SERVER STATS SYSTEM
-- =====================================================

-- Daily stats (Character database)
/*
DROP TABLE IF EXISTS `custom_server_stats_daily`;
CREATE TABLE `custom_server_stats_daily` (
    `date` DATE NOT NULL,
    `logins` INT UNSIGNED NOT NULL DEFAULT 0,
    `new_accounts` INT UNSIGNED NOT NULL DEFAULT 0,
    `gold_earned` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `items_looted` INT UNSIGNED NOT NULL DEFAULT 0,
    `mobs_killed` INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `custom_server_stats_alltime`;
CREATE TABLE `custom_server_stats_alltime` (
    `id` INT UNSIGNED NOT NULL DEFAULT 1,
    `total_mobs_killed` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `total_bosses_killed` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `total_deaths` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `total_items_looted` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `total_quests_completed` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `total_arena_matches` INT UNSIGNED NOT NULL DEFAULT 0,
    `total_bgs_played` INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Initialize all-time stats
INSERT INTO `custom_server_stats_alltime` (`id`) VALUES (1) ON DUPLICATE KEY UPDATE id = id;
*/

-- =====================================================
-- CHANGELOG SYSTEM
-- =====================================================

-- Changelog entries (World database)
DROP TABLE IF EXISTS `custom_changelog`;
CREATE TABLE `custom_changelog` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `version` VARCHAR(20) NOT NULL,
    `title` VARCHAR(200) NOT NULL,
    `description` TEXT NOT NULL,
    `category` TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `timestamp` INT UNSIGNED NOT NULL,
    `important` TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    INDEX `idx_timestamp` (`timestamp`),
    INDEX `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Sample changelog entries
INSERT INTO `custom_changelog` (`version`, `title`, `description`, `category`, `timestamp`, `important`) VALUES
('1.0.0', 'Server Launch', 'Welcome to our custom WoW server! Enjoy your adventure.', 5, UNIX_TIMESTAMP() - 604800, 1),
('1.0.1', 'Transmog System Added', 'You can now change the appearance of your gear! Visit the Transmogrifier NPC.', 1, UNIX_TIMESTAMP() - 518400, 1),
('1.0.2', 'Mythic+ Dungeons', 'Challenge yourself with scaling dungeon difficulty and compete on leaderboards!', 4, UNIX_TIMESTAMP() - 432000, 1),
('1.0.3', 'Custom Titles System', 'Earn powerful titles that grant 5-25% stat bonuses!', 1, UNIX_TIMESTAMP() - 345600, 0),
('1.0.4', 'Talent Prestige', 'Earn bonus talent points through the prestige system!', 1, UNIX_TIMESTAMP() - 259200, 0),
('1.0.5', 'Bug Fixes', 'Fixed various issues with loot and quest systems.', 2, UNIX_TIMESTAMP() - 172800, 0),
('1.0.6', 'Balance Update', 'Adjusted stats on several custom items for better balance.', 3, UNIX_TIMESTAMP() - 86400, 0);

-- Character changelog read tracking (Character database)
/*
DROP TABLE IF EXISTS `character_changelog_read`;
CREATE TABLE `character_changelog_read` (
    `guid` INT UNSIGNED NOT NULL,
    `last_read_id` INT UNSIGNED NOT NULL DEFAULT 0,
    `last_read_time` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
*/

-- =====================================================
-- TALENT PRESTIGE SYSTEM
-- =====================================================

-- Prestige levels (World database)
DROP TABLE IF EXISTS `custom_talent_prestige_levels`;
CREATE TABLE `custom_talent_prestige_levels` (
    `level` TINYINT UNSIGNED NOT NULL,
    `bonus_talent_points` TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `requirement_type` TINYINT UNSIGNED NOT NULL,
    `requirement_value` INT UNSIGNED NOT NULL,
    `name` VARCHAR(50) NOT NULL,
    `description` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Prestige levels with requirements
-- requirement_type: 1=Max level chars, 2=Playtime hours, 3=HKs, 4=Boss kills, 5=Achievement points
INSERT INTO `custom_talent_prestige_levels` VALUES
(1, 1, 1, 1, 'Initiate', 'Have 1 max level character'),
(2, 1, 2, 24, 'Dedicated', 'Play for 24 hours total'),
(3, 1, 1, 2, 'Altoholic', 'Have 2 max level characters'),
(4, 1, 2, 72, 'Committed', 'Play for 72 hours total'),
(5, 1, 3, 1000, 'Combatant', 'Earn 1000 honorable kills'),
(6, 1, 2, 168, 'Devoted', 'Play for 168 hours (1 week) total'),
(7, 1, 1, 3, 'Collector', 'Have 3 max level characters'),
(8, 1, 3, 5000, 'Warmonger', 'Earn 5000 honorable kills'),
(9, 1, 2, 336, 'Veteran', 'Play for 336 hours (2 weeks) total'),
(10, 2, 3, 10000, 'Legend', 'Earn 10000 honorable kills');

-- Prestige settings (World database)
DROP TABLE IF EXISTS `custom_talent_prestige_settings`;
CREATE TABLE `custom_talent_prestige_settings` (
    `setting_name` VARCHAR(50) NOT NULL,
    `setting_value` INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`setting_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `custom_talent_prestige_settings` VALUES
('max_bonus_points', 10);  -- Max +10 talent points from prestige

-- Account prestige data (Character database)
/*
DROP TABLE IF EXISTS `account_talent_prestige`;
CREATE TABLE `account_talent_prestige` (
    `account_id` INT UNSIGNED NOT NULL,
    `prestige_level` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `unlocked_date` INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
*/

-- =====================================================
-- NPC SPAWN TEMPLATES
-- =====================================================

-- You can spawn these NPCs in your world using:
-- INSERT INTO creature_template (entry, name, subname, ...) VALUES (...);
--
-- Suggested NPC entries (use entries in 900000+ range):
-- 900001: Transmogrifier
-- 900002: Mythic+ Master
-- 900003: Title Master
-- 900004: Server Statistics
-- 900005: Changelog Herald
-- 900006: Prestige Master
