-- ============================================================================
-- VIP SYSTEM
-- Premium perks for VIP players: Dual Wield, Speed Buff, World Chat Badge
-- ============================================================================

-- ============================================================================
-- VIP SETTINGS TABLE (World Database)
-- ============================================================================

DROP TABLE IF EXISTS `custom_vip_settings`;
CREATE TABLE `custom_vip_settings` (
    `setting_key` VARCHAR(50) NOT NULL,
    `setting_value` VARCHAR(255) NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='VIP system settings';

INSERT INTO `custom_vip_settings` (`setting_key`, `setting_value`, `description`) VALUES
('enabled', '1', 'Enable/disable VIP system'),
('speed_buff_spell', '65081', 'Speed buff spell ID (default: 10% mount speed)'),
('speed_buff_percent', '10', 'Speed increase percentage'),
('dual_wield_spell', '674', 'Dual Wield spell ID'),
('chat_badge', '[VIP]', 'Badge shown in world chat'),
('chat_badge_color', 'ff00ff', 'Badge color (magenta)'),
('login_message', '1', 'Show VIP welcome message on login'),
('announce_login', '0', 'Announce VIP login to world');

-- ============================================================================
-- VIP PERKS TABLE (World Database)
-- Define additional perks that VIPs receive
-- ============================================================================

DROP TABLE IF EXISTS `custom_vip_perks`;
CREATE TABLE `custom_vip_perks` (
    `perk_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    `perk_type` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '0=Spell, 1=Aura, 2=Item, 3=Title',
    `value` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Spell ID, Item ID, or Title ID',
    `apply_on_login` TINYINT(1) NOT NULL DEFAULT 1,
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`perk_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='VIP perks definitions';

-- Default VIP perks
INSERT INTO `custom_vip_perks` (`name`, `description`, `perk_type`, `value`, `apply_on_login`, `enabled`) VALUES
('Dual Wield', 'Ability to dual wield weapons', 0, 674, 1, 1),
('Speed Buff', 'Permanent 10% movement speed increase', 1, 65081, 1, 1);

-- ============================================================================
-- VIP ACCOUNTS TABLE (Auth Database)
-- Track which accounts have VIP status
-- Run this on your AUTH database!
-- ============================================================================

-- NOTE: Run this on AUTH database
-- DROP TABLE IF EXISTS `custom_vip_accounts`;
-- CREATE TABLE `custom_vip_accounts` (
--     `account_id` INT UNSIGNED NOT NULL,
--     `vip_level` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1=VIP, 2=VIP+, 3=VIP++',
--     `start_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     `end_date` TIMESTAMP NULL DEFAULT NULL COMMENT 'NULL = permanent',
--     `granted_by` VARCHAR(50) DEFAULT NULL,
--     `notes` VARCHAR(255) DEFAULT NULL,
--     PRIMARY KEY (`account_id`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='VIP account status';

-- ============================================================================
-- ALTERNATIVE: Use existing account_access for VIP
-- Security level 0 = Player, we'll use a custom flag in realmlist
-- OR we can add a simple table to the CHARACTER database instead
-- ============================================================================

-- Character database version (easier to manage)
DROP TABLE IF EXISTS `character_vip`;
CREATE TABLE `character_vip` (
    `account_id` INT UNSIGNED NOT NULL,
    `vip_level` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1=VIP, 2=VIP+, 3=VIP++',
    `start_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `end_date` TIMESTAMP NULL DEFAULT NULL COMMENT 'NULL = permanent',
    `granted_by` VARCHAR(50) DEFAULT NULL,
    `total_days` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Total days of VIP',
    PRIMARY KEY (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='VIP account status';

-- ============================================================================
-- ADMIN COMMANDS FOR VIP MANAGEMENT (Security Level 3+)
-- .vip add <player> - Add permanent VIP status
-- .vip remove <player> - Remove VIP status
-- .vip check <player> - Check VIP status
-- .vip list - List all VIPs
-- ============================================================================

-- ============================================================================
-- VIP TOKEN ITEM (World Database)
-- Use this item to activate permanent VIP status
-- Item Entry: 700001
-- ============================================================================

DELETE FROM `item_template` WHERE `entry` = 700001;
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `SoundOverrideSubclass`, `name`, `displayid`, `Quality`, `Flags`, `FlagsExtra`, `BuyCount`, `BuyPrice`, `SellPrice`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `RequiredSkill`, `RequiredSkillRank`, `requiredspell`, `requiredhonorrank`, `RequiredCityRank`, `RequiredReputationFaction`, `RequiredReputationRank`, `maxcount`, `stackable`, `ContainerSlots`, `StatsCount`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `stat_type4`, `stat_value4`, `stat_type5`, `stat_value5`, `stat_type6`, `stat_value6`, `stat_type7`, `stat_value7`, `stat_type8`, `stat_value8`, `stat_type9`, `stat_value9`, `stat_type10`, `stat_value10`, `ScalingStatDistribution`, `ScalingStatValue`, `dmg_min1`, `dmg_max1`, `dmg_type1`, `dmg_min2`, `dmg_max2`, `dmg_type2`, `armor`, `holy_res`, `fire_res`, `nature_res`, `frost_res`, `shadow_res`, `arcane_res`, `delay`, `ammo_type`, `RangedModRange`, `spellid_1`, `spelltrigger_1`, `spellcharges_1`, `spellppmRate_1`, `spellcooldown_1`, `spellcategory_1`, `spellcategorycooldown_1`, `spellid_2`, `spelltrigger_2`, `spellcharges_2`, `spellppmRate_2`, `spellcooldown_2`, `spellcategory_2`, `spellcategorycooldown_2`, `spellid_3`, `spelltrigger_3`, `spellcharges_3`, `spellppmRate_3`, `spellcooldown_3`, `spellcategory_3`, `spellcategorycooldown_3`, `spellid_4`, `spelltrigger_4`, `spellcharges_4`, `spellppmRate_4`, `spellcooldown_4`, `spellcategory_4`, `spellcategorycooldown_4`, `spellid_5`, `spelltrigger_5`, `spellcharges_5`, `spellppmRate_5`, `spellcooldown_5`, `spellcategory_5`, `spellcategorycooldown_5`, `bonding`, `description`, `PageText`, `LanguageID`, `PageMaterial`, `startquest`, `lockid`, `Material`, `sheath`, `RandomProperty`, `RandomSuffix`, `block`, `itemset`, `MaxDurability`, `area`, `Map`, `BagFamily`, `TotemCategory`, `socketColor_1`, `socketContent_1`, `socketColor_2`, `socketContent_2`, `socketColor_3`, `socketContent_3`, `socketBonus`, `GemProperties`, `RequiredDisenchantSkill`, `ArmorDamageModifier`, `duration`, `ItemLimitCategory`, `HolidayId`, `ScriptName`, `DisenchantID`, `FoodType`, `minMoneyLoot`, `maxMoneyLoot`, `flagsCustom`, `VerifiedBuild`)
VALUES
(700001, 15, 0, -1, 'VIP Token', 6948, 4, 0, 0, 1, 0, 0, 0, -1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 'Use: Activate permanent VIP status with Dual Wield and Speed Buff.', 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 'item_vip_token', 0, 0, 0, 0, 0, 0);

-- ============================================================================
-- EXAMPLE: Grant VIP to account ID 1 permanently
-- ============================================================================

-- INSERT INTO `character_vip` (`account_id`, `vip_level`, `end_date`, `granted_by`) VALUES
-- (1, 1, NULL, 'Console');

-- ============================================================================
-- EXAMPLE: Grant VIP to account ID 2 for 30 days
-- ============================================================================

-- INSERT INTO `character_vip` (`account_id`, `vip_level`, `end_date`, `granted_by`, `total_days`) VALUES
-- (2, 1, DATE_ADD(NOW(), INTERVAL 30 DAY), 'Admin', 30);

-- ============================================================================
-- HELPFUL QUERIES
-- ============================================================================

-- Check if account is VIP:
-- SELECT * FROM character_vip WHERE account_id = <id> AND (end_date IS NULL OR end_date > NOW());

-- List all active VIPs:
-- SELECT cv.*, a.username FROM character_vip cv
-- JOIN auth.account a ON cv.account_id = a.id
-- WHERE cv.end_date IS NULL OR cv.end_date > NOW();

-- Expired VIPs:
-- SELECT * FROM character_vip WHERE end_date IS NOT NULL AND end_date < NOW();
