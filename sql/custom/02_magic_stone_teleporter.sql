-- ============================================================================
-- MAGIC STONE TELEPORTER SYSTEM
-- A right-click item that opens a gossip menu for teleportation
-- ============================================================================

-- Custom item entry (use high number to avoid conflicts)
SET @MAGIC_STONE_ENTRY := 100000;
SET @MAGIC_STONE_SCRIPT := 'item_magic_stone';

-- ============================================================================
-- TELEPORT DESTINATIONS TABLE
-- Add your custom teleport locations here!
-- ============================================================================

DROP TABLE IF EXISTS `custom_teleport_destinations`;
CREATE TABLE `custom_teleport_destinations` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `category_id` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Category for submenu grouping',
    `category_name` VARCHAR(50) NOT NULL DEFAULT 'General' COMMENT 'Category display name',
    `name` VARCHAR(100) NOT NULL COMMENT 'Teleport destination name',
    `description` VARCHAR(255) DEFAULT NULL COMMENT 'Optional description shown in menu',
    `map_id` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `x` FLOAT NOT NULL DEFAULT 0,
    `y` FLOAT NOT NULL DEFAULT 0,
    `z` FLOAT NOT NULL DEFAULT 0,
    `orientation` FLOAT NOT NULL DEFAULT 0,
    `min_level` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Minimum level required',
    `max_level` TINYINT UNSIGNED NOT NULL DEFAULT 80 COMMENT 'Maximum level allowed (0 = no max)',
    `required_item` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Required item to use this teleport',
    `required_quest` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Required completed quest',
    `cost_money` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Gold cost in copper (10000 = 1g)',
    `cost_item` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Item consumed on teleport',
    `cost_item_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Amount of item consumed',
    `faction` TINYINT NOT NULL DEFAULT 0 COMMENT '0=Both, 1=Alliance, 2=Horde',
    `gm_only` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1=GM only destination',
    `enabled` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '0=Disabled, 1=Enabled',
    `sort_order` INT NOT NULL DEFAULT 0 COMMENT 'Display order in menu',
    PRIMARY KEY (`id`),
    INDEX `idx_category` (`category_id`),
    INDEX `idx_enabled` (`enabled`),
    INDEX `idx_faction` (`faction`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Magic Stone teleport destinations';

-- ============================================================================
-- CATEGORY TABLE (for organizing teleports into submenus)
-- ============================================================================

DROP TABLE IF EXISTS `custom_teleport_categories`;
CREATE TABLE `custom_teleport_categories` (
    `id` TINYINT UNSIGNED NOT NULL,
    `name` VARCHAR(50) NOT NULL,
    `icon` VARCHAR(50) DEFAULT NULL COMMENT 'Icon to display (optional)',
    `sort_order` INT NOT NULL DEFAULT 0,
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Magic Stone teleport categories';

-- ============================================================================
-- DEFAULT CATEGORIES
-- ============================================================================

INSERT INTO `custom_teleport_categories` (`id`, `name`, `icon`, `sort_order`, `enabled`) VALUES
(0, 'General', NULL, 0, 1),
(1, 'Major Cities', NULL, 10, 1),
(2, 'Dungeons', NULL, 20, 1),
(3, 'Raids', NULL, 30, 1),
(4, 'Zones', NULL, 40, 1),
(5, 'Custom Areas', NULL, 50, 1),
(6, 'Events', NULL, 60, 1),
(7, 'GM Only', NULL, 100, 1);

-- ============================================================================
-- DEFAULT TELEPORT DESTINATIONS
-- ============================================================================

INSERT INTO `custom_teleport_destinations`
(`category_id`, `category_name`, `name`, `map_id`, `x`, `y`, `z`, `orientation`, `min_level`, `faction`, `sort_order`, `enabled`) VALUES

-- Major Cities (Category 1)
(1, 'Major Cities', 'Stormwind', 0, -8833.38, 628.628, 94.0066, 1.0, 1, 1, 10, 1),
(1, 'Major Cities', 'Ironforge', 0, -4918.88, -940.406, 501.564, 5.42, 1, 1, 11, 1),
(1, 'Major Cities', 'Darnassus', 1, 9951.52, 2280.32, 1341.39, 1.59, 1, 1, 12, 1),
(1, 'Major Cities', 'Exodar', 530, -3965.7, -11653.6, -138.844, 0.0, 1, 1, 13, 1),
(1, 'Major Cities', 'Orgrimmar', 1, 1676.21, -4315.29, 61.5293, 0.0, 1, 2, 20, 1),
(1, 'Major Cities', 'Thunder Bluff', 1, -1274.45, 71.8601, 128.159, 0.0, 1, 2, 21, 1),
(1, 'Major Cities', 'Undercity', 0, 1586.48, 239.562, -52.149, 0.0, 1, 2, 22, 1),
(1, 'Major Cities', 'Silvermoon', 530, 9487.69, -7279.2, 14.2866, 0.0, 1, 2, 23, 1),
(1, 'Major Cities', 'Shattrath', 530, -1850.21, 5435.82, -10.9614, 3.40, 1, 0, 30, 1),
(1, 'Major Cities', 'Dalaran', 571, 5804.15, 624.771, 647.767, 1.64, 68, 0, 31, 1),

-- Dungeons (Category 2)
(2, 'Dungeons', 'Deadmines Entrance', 0, -11208.3, 1685.23, 24.7931, 0.0, 15, 0, 10, 1),
(2, 'Dungeons', 'Scarlet Monastery', 0, 2843.89, -693.74, 139.316, 0.0, 26, 0, 11, 1),
(2, 'Dungeons', 'Blackrock Mountain', 0, -7535.43, -1212.04, 285.453, 0.0, 50, 0, 12, 1),
(2, 'Dungeons', 'Hellfire Citadel', 530, -305.816, 3056.4, -2.47033, 2.01, 58, 0, 20, 1),
(2, 'Dungeons', 'Utgarde Keep', 571, 1219.72, -4865.28, 41.2479, 0.0, 68, 0, 30, 1),

-- Raids (Category 3)
(3, 'Raids', 'Molten Core', 0, -7510.55, -1036.69, 180.936, 0.0, 60, 0, 10, 1),
(3, 'Raids', 'Karazhan', 0, -11118.8, -2010.84, 47.0807, 0.0, 68, 0, 20, 1),
(3, 'Raids', 'Naxxramas (Northrend)', 571, 3668.72, -1262.46, 243.622, 0.0, 80, 0, 30, 1),
(3, 'Raids', 'Ulduar', 571, 9222.88, -1113.59, 1216.12, 0.0, 80, 0, 31, 1),
(3, 'Raids', 'Icecrown Citadel', 571, 5855.22, 2102.03, 635.991, 0.0, 80, 0, 32, 1),

-- Zones (Category 4)
(4, 'Zones', 'Elwynn Forest', 0, -9449.06, 64.8392, 56.3581, 0.0, 1, 0, 10, 1),
(4, 'Zones', 'Durotar', 1, 338.22, -4706.52, 15.4649, 0.0, 1, 0, 11, 1),
(4, 'Zones', 'Tanaris (Gadgetzan)', 1, -7177.15, -3785.34, 8.36981, 0.0, 40, 0, 20, 1),
(4, 'Zones', 'Wintergrasp', 571, 5136.0, 2840.0, 408.0, 0.0, 77, 0, 30, 1),
(4, 'Zones', 'Grizzly Hills', 571, 3560.0, -4805.0, 227.0, 0.0, 73, 0, 31, 1),

-- Custom Areas (Category 5) - Add your custom zones here!
(5, 'Custom Areas', 'Mall / Shopping Area', 1, 16222.0, 16252.0, 13.2, 1.65, 1, 0, 10, 1),
(5, 'Custom Areas', 'Duel Zone', 0, -13229.6, 226.263, 33.6833, 1.13, 1, 0, 20, 1),
(5, 'Custom Areas', 'VIP Lounge', 1, 16202.0, 16202.0, 1.0, 0.0, 1, 0, 30, 0), -- Disabled by default

-- GM Only (Category 7)
(7, 'GM Only', 'GM Island', 1, 16222.1, 16252.1, 12.5872, 1.0, 1, 0, 10, 1);

-- ============================================================================
-- MAGIC STONE ITEM
-- ============================================================================

-- Delete if exists (for updates)
DELETE FROM `item_template` WHERE `entry` = @MAGIC_STONE_ENTRY;

-- Insert the Magic Stone item
INSERT INTO `item_template` (
    `entry`, `class`, `subclass`, `SoundOverrideSubclass`, `name`, `displayid`,
    `Quality`, `Flags`, `FlagsExtra`, `BuyCount`, `BuyPrice`, `SellPrice`,
    `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`,
    `RequiredSkill`, `RequiredSkillRank`, `requiredspell`, `requiredhonorrank`,
    `RequiredCityRank`, `RequiredReputationFaction`, `RequiredReputationRank`,
    `maxcount`, `stackable`, `ContainerSlots`, `StatsCount`,
    `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`,
    `stat_type3`, `stat_value3`, `stat_type4`, `stat_value4`,
    `stat_type5`, `stat_value5`, `stat_type6`, `stat_value6`,
    `stat_type7`, `stat_value7`, `stat_type8`, `stat_value8`,
    `stat_type9`, `stat_value9`, `stat_type10`, `stat_value10`,
    `ScalingStatDistribution`, `ScalingStatValue`, `dmg_min1`, `dmg_max1`,
    `dmg_type1`, `dmg_min2`, `dmg_max2`, `dmg_type2`, `armor`, `holy_res`,
    `fire_res`, `nature_res`, `frost_res`, `shadow_res`, `arcane_res`, `delay`,
    `ammo_type`, `RangedModRange`, `spellid_1`, `spelltrigger_1`, `spellcharges_1`,
    `spellppmRate_1`, `spellcooldown_1`, `spellcategory_1`, `spellcategorycooldown_1`,
    `spellid_2`, `spelltrigger_2`, `spellcharges_2`, `spellppmRate_2`, `spellcooldown_2`,
    `spellcategory_2`, `spellcategorycooldown_2`, `spellid_3`, `spelltrigger_3`,
    `spellcharges_3`, `spellppmRate_3`, `spellcooldown_3`, `spellcategory_3`,
    `spellcategorycooldown_3`, `spellid_4`, `spelltrigger_4`, `spellcharges_4`,
    `spellppmRate_4`, `spellcooldown_4`, `spellcategory_4`, `spellcategorycooldown_4`,
    `spellid_5`, `spelltrigger_5`, `spellcharges_5`, `spellppmRate_5`, `spellcooldown_5`,
    `spellcategory_5`, `spellcategorycooldown_5`, `bonding`, `description`,
    `PageText`, `LanguageID`, `PageMaterial`, `startquest`, `lockid`, `Material`,
    `sheath`, `RandomProperty`, `RandomSuffix`, `block`, `itemset`, `MaxDurability`,
    `area`, `Map`, `BagFamily`, `TotemCategory`, `socketColor_1`, `socketContent_1`,
    `socketColor_2`, `socketContent_2`, `socketColor_3`, `socketContent_3`,
    `socketBonus`, `GemProperties`, `RequiredDisenchantSkill`, `ArmorDamageModifier`,
    `duration`, `ItemLimitCategory`, `HolidayId`, `ScriptName`, `DisenchantID`,
    `FoodType`, `minMoneyLoot`, `maxMoneyLoot`, `flagsCustom`, `VerifiedBuild`
) VALUES (
    @MAGIC_STONE_ENTRY, -- entry
    15, -- class (Miscellaneous)
    0, -- subclass (Junk)
    -1, -- SoundOverrideSubclass
    'Magic Stone', -- name
    6339, -- displayid (purple crystal icon)
    4, -- Quality (4 = Epic purple)
    0, -- Flags
    0, -- FlagsExtra
    1, -- BuyCount
    0, -- BuyPrice
    0, -- SellPrice
    0, -- InventoryType (0 = Non-equippable)
    -1, -- AllowableClass (-1 = All)
    -1, -- AllowableRace (-1 = All)
    1, -- ItemLevel
    1, -- RequiredLevel
    0, 0, 0, 0, 0, 0, 0, -- Required skill/spell/honor/city/rep
    1, -- maxcount (unique)
    1, -- stackable
    0, -- ContainerSlots
    0, -- StatsCount
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -- Stats
    0, 0, -- Scaling
    0, 0, 0, 0, 0, 0, -- Damage
    0, -- armor
    0, 0, 0, 0, 0, 0, -- Resistances
    0, -- delay
    0, 0, -- ammo
    0, 0, 0, 0, 0, 0, 0, -- Spell 1 (empty - handled by script)
    0, 0, 0, 0, 0, 0, 0, -- Spell 2
    0, 0, 0, 0, 0, 0, 0, -- Spell 3
    0, 0, 0, 0, 0, 0, 0, -- Spell 4
    0, 0, 0, 0, 0, 0, 0, -- Spell 5
    1, -- bonding (1 = Binds when picked up)
    'Right-click to open the teleportation menu.', -- description
    0, 0, 0, 0, 0, -- PageText, Language, Material, startquest, lockid
    -1, -- Material (-1 = Consumable)
    0, -- sheath
    0, 0, -- Random property/suffix
    0, -- block
    0, -- itemset
    0, -- MaxDurability
    0, 0, -- area, Map
    0, -- BagFamily
    0, -- TotemCategory
    0, 0, 0, 0, 0, 0, -- Sockets
    0, 0, -- socketBonus, GemProperties
    -1, -- RequiredDisenchantSkill
    0, -- ArmorDamageModifier
    0, -- duration
    0, -- ItemLimitCategory
    0, -- HolidayId
    @MAGIC_STONE_SCRIPT, -- ScriptName
    0, -- DisenchantID
    0, -- FoodType
    0, 0, -- Money loot
    0, -- flagsCustom
    0 -- VerifiedBuild
);

-- ============================================================================
-- HELPFUL QUERIES FOR MANAGING TELEPORTS
-- ============================================================================

-- Add a new teleport destination:
-- INSERT INTO custom_teleport_destinations
--     (category_id, category_name, name, map_id, x, y, z, orientation, min_level, faction, enabled)
-- VALUES (5, 'Custom Areas', 'My New Zone', 0, 0, 0, 0, 0, 1, 0, 1);

-- Disable a teleport:
-- UPDATE custom_teleport_destinations SET enabled = 0 WHERE name = 'Some Location';

-- Change teleport coordinates:
-- UPDATE custom_teleport_destinations SET x = 100, y = 200, z = 50 WHERE name = 'Some Location';

-- Add level requirement:
-- UPDATE custom_teleport_destinations SET min_level = 60 WHERE name = 'Some Location';

-- Make Alliance only:
-- UPDATE custom_teleport_destinations SET faction = 1 WHERE name = 'Some Location';

-- Make Horde only:
-- UPDATE custom_teleport_destinations SET faction = 2 WHERE name = 'Some Location';

-- Add gold cost (1g = 10000 copper):
-- UPDATE custom_teleport_destinations SET cost_money = 10000 WHERE name = 'Some Location';
