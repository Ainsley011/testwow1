-- ============================================================================
-- MAGIC STONE TELEPORTER SYSTEM
-- A right-click item that opens a gossip menu for teleportation
-- ============================================================================

-- Custom item entry (use high number to avoid conflicts)
SET @MAGIC_STONE_ENTRY := 100000;
SET @MAGIC_STONE_SCRIPT := 'item_magic_stone';

-- ============================================================================
-- CATEGORY TABLE (for organizing teleports into submenus)
-- ============================================================================

DROP TABLE IF EXISTS `custom_teleport_categories`;
CREATE TABLE `custom_teleport_categories` (
    `id` TINYINT UNSIGNED NOT NULL,
    `name` VARCHAR(50) NOT NULL COMMENT 'Category name',
    `color_code` VARCHAR(10) DEFAULT NULL COMMENT 'WoW color code (e.g., ff00ff00 for green)',
    `icon_id` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Gossip icon (0=chat, 1=vendor, 2=taxi, 3=trainer, 4=cog, 6=money, 7=talk, 9=swords, 10=dot)',
    `sort_order` INT NOT NULL DEFAULT 0,
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Magic Stone teleport categories';

-- ============================================================================
-- TELEPORT DESTINATIONS TABLE
-- Add your custom teleport locations here!
-- ============================================================================

DROP TABLE IF EXISTS `custom_teleport_destinations`;
CREATE TABLE `custom_teleport_destinations` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `category_id` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Category for submenu grouping',
    `name` VARCHAR(100) NOT NULL COMMENT 'Teleport destination name',
    `color_code` VARCHAR(10) DEFAULT NULL COMMENT 'WoW color code for this destination',
    `icon_id` TINYINT UNSIGNED NOT NULL DEFAULT 2 COMMENT 'Gossip icon (default: taxi/flightpath)',
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
-- DEFAULT CATEGORIES
-- Icon IDs: 0=chat, 1=vendor, 2=taxi/flightpath, 3=trainer/book, 4=cog,
--           5=cog, 6=money bag, 7=talk bubble, 9=crossed swords, 10=dot
-- Color codes: WoW uses |cAARRGGBB format, we store just RRGGBB or AARRGGBB
--   ff0000 = Red, 00ff00 = Green, 0000ff = Blue, ffff00 = Yellow
--   ff8000 = Orange, 00ffff = Cyan, ff00ff = Purple, ffffff = White
-- ============================================================================

INSERT INTO `custom_teleport_categories` (`id`, `name`, `color_code`, `icon_id`, `sort_order`, `enabled`) VALUES
(1, 'Major Cities', '00ff00', 2, 10, 1),           -- Green, taxi icon
(2, 'Dungeons', 'ffff00', 3, 20, 1),               -- Yellow, book icon
(3, 'Raids', 'ff8000', 9, 30, 1),                  -- Orange, swords icon
(4, 'World Bosses', 'ff0000', 9, 35, 1),           -- Red, swords icon
(5, 'Zones & Leveling', '00ffff', 2, 40, 1),       -- Cyan, taxi icon
(6, 'Custom Instances', 'ff00ff', 4, 50, 1),       -- Purple, cog icon
(7, 'World Teleports', 'ffffff', 10, 55, 1),       -- White, dot icon
(8, 'Shopping & Services', 'ffd700', 1, 60, 1),    -- Gold, vendor icon
(9, 'Events & Arenas', '1eff00', 9, 70, 1),        -- Bright green, swords
(10, 'GM Only', 'ff0000', 0, 100, 1);              -- Red, chat icon

-- ============================================================================
-- DEFAULT TELEPORT DESTINATIONS
-- ============================================================================

INSERT INTO `custom_teleport_destinations`
(`category_id`, `name`, `color_code`, `icon_id`, `map_id`, `x`, `y`, `z`, `orientation`, `min_level`, `faction`, `sort_order`, `enabled`) VALUES

-- Major Cities (Category 1) - Alliance
(1, 'Stormwind', '0080ff', 2, 0, -8833.38, 628.628, 94.0066, 1.0, 1, 1, 10, 1),
(1, 'Ironforge', '0080ff', 2, 0, -4918.88, -940.406, 501.564, 5.42, 1, 1, 11, 1),
(1, 'Darnassus', '0080ff', 2, 1, 9951.52, 2280.32, 1341.39, 1.59, 1, 1, 12, 1),
(1, 'Exodar', '0080ff', 2, 530, -3965.7, -11653.6, -138.844, 0.0, 1, 1, 13, 1),

-- Major Cities (Category 1) - Horde
(1, 'Orgrimmar', 'ff0000', 2, 1, 1676.21, -4315.29, 61.5293, 0.0, 1, 2, 20, 1),
(1, 'Thunder Bluff', 'ff0000', 2, 1, -1274.45, 71.8601, 128.159, 0.0, 1, 2, 21, 1),
(1, 'Undercity', 'ff0000', 2, 0, 1586.48, 239.562, -52.149, 0.0, 1, 2, 22, 1),
(1, 'Silvermoon City', 'ff0000', 2, 530, 9487.69, -7279.2, 14.2866, 0.0, 1, 2, 23, 1),

-- Major Cities (Category 1) - Neutral
(1, 'Shattrath City', 'ffff00', 2, 530, -1850.21, 5435.82, -10.9614, 3.40, 58, 0, 30, 1),
(1, 'Dalaran', 'ff00ff', 2, 571, 5804.15, 624.771, 647.767, 1.64, 68, 0, 31, 1),

-- Dungeons (Category 2) - Classic
(2, 'Deadmines', NULL, 3, 0, -11208.3, 1685.23, 24.7931, 0.0, 15, 0, 10, 1),
(2, 'Scarlet Monastery', NULL, 3, 0, 2843.89, -693.74, 139.316, 0.0, 26, 0, 11, 1),
(2, 'Blackrock Depths', NULL, 3, 0, -7535.43, -1212.04, 285.453, 0.0, 48, 0, 12, 1),
(2, 'Stratholme', NULL, 3, 0, 3352.92, -3379.03, 144.782, 0.0, 55, 0, 13, 1),
(2, 'Scholomance', NULL, 3, 0, 1269.64, -2556.21, 93.6088, 0.0, 55, 0, 14, 1),

-- Dungeons (Category 2) - TBC
(2, 'Hellfire Citadel', 'ff8000', 3, 530, -305.816, 3056.4, -2.47033, 2.01, 58, 0, 20, 1),
(2, 'Coilfang Reservoir', 'ff8000', 3, 530, 738.865, 6865.77, -69.4659, 0.0, 60, 0, 21, 1),
(2, 'Auchindoun', 'ff8000', 3, 530, -3322.92, 4931.02, -100.508, 0.0, 62, 0, 22, 1),

-- Dungeons (Category 2) - WotLK
(2, 'Utgarde Keep', '00ffff', 3, 571, 1219.72, -4865.28, 41.2479, 0.0, 68, 0, 30, 1),
(2, 'The Nexus', '00ffff', 3, 571, 3783.0, 6941.0, 104.0, 0.0, 68, 0, 31, 1),
(2, 'Azjol-Nerub', '00ffff', 3, 571, 3707.0, 2150.0, 36.0, 0.0, 72, 0, 32, 1),

-- Raids (Category 3) - Classic
(3, 'Molten Core', 'ffff00', 9, 0, -7510.55, -1036.69, 180.936, 0.0, 60, 0, 10, 1),
(3, 'Blackwing Lair', 'ffff00', 9, 0, -7665.55, -1102.49, 400.679, 0.0, 60, 0, 11, 1),
(3, 'Onyxia''s Lair', 'ffff00', 9, 1, -4708.27, -3727.64, 54.5589, 0.0, 60, 0, 12, 1),
(3, 'Ahn''Qiraj', 'ffff00', 9, 1, -8409.82, 1499.06, 27.3615, 0.0, 60, 0, 13, 1),

-- Raids (Category 3) - TBC
(3, 'Karazhan', 'ff8000', 9, 0, -11118.8, -2010.84, 47.0807, 0.0, 68, 0, 20, 1),
(3, 'Gruul''s Lair', 'ff8000', 9, 530, 3539.01, 5082.36, 1.69107, 0.0, 70, 0, 21, 1),
(3, 'Serpentshrine Cavern', 'ff8000', 9, 530, 829.809, 6865.46, -66.3573, 0.0, 70, 0, 22, 1),
(3, 'Black Temple', 'ff8000', 9, 530, -3610.72, 324.988, 37.4, 0.0, 70, 0, 23, 1),
(3, 'Sunwell Plateau', 'ff8000', 9, 530, 12560.7, -6774.58, 15.0904, 0.0, 70, 0, 24, 1),

-- Raids (Category 3) - WotLK
(3, 'Naxxramas', '00ffff', 9, 571, 3668.72, -1262.46, 243.622, 0.0, 80, 0, 30, 1),
(3, 'Ulduar', '00ffff', 9, 571, 9222.88, -1113.59, 1216.12, 0.0, 80, 0, 31, 1),
(3, 'Trial of the Crusader', '00ffff', 9, 571, 8515.61, 714.153, 558.248, 0.0, 80, 0, 32, 1),
(3, 'Icecrown Citadel', 'ff0000', 9, 571, 5855.22, 2102.03, 635.991, 0.0, 80, 0, 33, 1),

-- World Bosses (Category 4)
(4, 'Azuregos', 'ff0000', 9, 1, 2632.32, -6008.45, 104.656, 0.0, 55, 0, 10, 1),
(4, 'Lord Kazzak', 'ff0000', 9, 0, -11813.5, -3197.23, -30.4093, 0.0, 55, 0, 11, 1),
(4, 'Emerald Dragons', 'ff0000', 9, 0, -10471.3, -439.914, 50.0967, 0.0, 55, 0, 12, 1),
(4, 'Doom Lord Kazzak', 'ff8000', 9, 530, -3558.73, 2505.91, 79.2, 0.0, 70, 0, 20, 1),

-- Zones & Leveling (Category 5)
(5, 'Elwynn Forest (1-10)', NULL, 2, 0, -9449.06, 64.8392, 56.3581, 0.0, 1, 0, 10, 1),
(5, 'Westfall (10-20)', NULL, 2, 0, -10628.1, 1036.68, 34.2326, 0.0, 10, 0, 11, 1),
(5, 'Duskwood (20-30)', NULL, 2, 0, -10569.3, -1168.67, 27.8547, 0.0, 20, 0, 12, 1),
(5, 'Stranglethorn Vale (30-45)', NULL, 2, 0, -11916.1, -1204.98, 92.2861, 0.0, 30, 0, 13, 1),
(5, 'Tanaris (40-50)', NULL, 2, 1, -7177.15, -3785.34, 8.36981, 0.0, 40, 0, 14, 1),
(5, 'Hellfire Peninsula (58-63)', 'ff8000', 2, 530, -248.49, 922.163, 84.3583, 0.0, 58, 0, 20, 1),
(5, 'Nagrand (64-67)', 'ff8000', 2, 530, -468.201, 8418.43, 28.7704, 0.0, 64, 0, 21, 1),
(5, 'Borean Tundra (68-72)', '00ffff', 2, 571, 2954.24, 5378.89, 60.4463, 0.0, 68, 0, 30, 1),
(5, 'Howling Fjord (68-72)', '00ffff', 2, 571, 588.141, -5095.67, 6.20601, 0.0, 68, 0, 31, 1),
(5, 'Grizzly Hills (73-75)', '00ffff', 2, 571, 3560.0, -4805.0, 227.0, 0.0, 73, 0, 32, 1),
(5, 'Storm Peaks (77-80)', '00ffff', 2, 571, 6120.46, -1013.89, 408.39, 0.0, 77, 0, 33, 1),

-- Custom Instances (Category 6) - Empty by default, add your own!
-- (6, 'My Custom Dungeon', 'ff00ff', 4, 0, 0, 0, 0, 0, 1, 0, 10, 1),

-- World Teleports (Category 7) - Add your custom world locations here!
(7, 'Booty Bay', NULL, 10, 0, -14302.4, 508.521, 8.83196, 0.0, 30, 0, 10, 1),
(7, 'Ratchet', NULL, 10, 1, -991.709, -3827.68, 5.86852, 0.0, 10, 0, 11, 1),
(7, 'Everlook', NULL, 10, 1, 6664.22, -4555.54, 718.624, 0.0, 50, 0, 12, 1),
(7, 'Mudsprocket', NULL, 10, 1, -4601.5, -3278.13, 33.9659, 0.0, 35, 0, 13, 1),

-- Shopping & Services (Category 8)
(8, 'Mall / Shopping Area', 'ffd700', 1, 1, 16222.0, 16252.0, 13.2, 1.65, 1, 0, 10, 1),
(8, 'Transmogrifier', 'ffd700', 1, 571, 5802.24, 588.47, 650.896, 0.0, 1, 0, 20, 1),
(8, 'Void Storage', 'ffd700', 6, 571, 5792.11, 591.13, 650.896, 0.0, 1, 0, 21, 1),

-- Events & Arenas (Category 9)
(9, 'Duel Zone', '1eff00', 9, 0, -13229.6, 226.263, 33.6833, 1.13, 1, 0, 10, 1),
(9, 'Gurubashi Arena', '1eff00', 9, 0, -13233.5, 227.517, 33.2213, 0.0, 30, 0, 11, 1),
(9, 'Ring of Trials (Nagrand)', 'ff8000', 9, 530, -1999.94, 6581.7, 11.32, 0.0, 64, 0, 20, 1),

-- GM Only (Category 10)
(10, 'GM Island', 'ff0000', 0, 1, 16222.1, 16252.1, 12.5872, 1.0, 1, 0, 10, 1),
(10, 'Developer Playground', 'ff0000', 0, 0, -8942.42, 517.09, 96.355, 0.0, 1, 0, 20, 1);

-- Mark GM Only destinations
UPDATE `custom_teleport_destinations` SET `gm_only` = 1 WHERE `category_id` = 10;

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
    5, -- Quality (5 = Legendary orange)
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

-- Add a new category:
-- INSERT INTO custom_teleport_categories (id, name, color_code, icon_id, sort_order, enabled)
-- VALUES (11, 'My Category', 'ff00ff', 4, 80, 1);

-- Add a new teleport destination:
-- INSERT INTO custom_teleport_destinations
--     (category_id, name, color_code, icon_id, map_id, x, y, z, orientation, min_level, faction, enabled)
-- VALUES (6, 'My Custom Instance', 'ff00ff', 4, 0, 0, 0, 0, 0, 1, 0, 1);

-- Disable a teleport:
-- UPDATE custom_teleport_destinations SET enabled = 0 WHERE name = 'Some Location';

-- Change destination color:
-- UPDATE custom_teleport_destinations SET color_code = 'ff0000' WHERE name = 'Some Location';

-- Add level requirement:
-- UPDATE custom_teleport_destinations SET min_level = 60 WHERE name = 'Some Location';

-- Make Alliance only:
-- UPDATE custom_teleport_destinations SET faction = 1 WHERE name = 'Some Location';

-- Make Horde only:
-- UPDATE custom_teleport_destinations SET faction = 2 WHERE name = 'Some Location';

-- ============================================================================
-- COLOR CODE REFERENCE:
-- WoW uses |cAARRGGBB format. In the color_code column, store RRGGBB or AARRGGBB
--
-- Common colors:
--   ff0000 = Red          00ff00 = Green        0000ff = Blue
--   ffff00 = Yellow       ff8000 = Orange       00ffff = Cyan
--   ff00ff = Purple       ffffff = White        808080 = Gray
--   ffd700 = Gold         1eff00 = Bright Green 0080ff = Light Blue
--
-- Item quality colors:
--   9d9d9d = Poor (gray)  ffffff = Common (white)
--   1eff00 = Uncommon     0070dd = Rare (blue)
--   a335ee = Epic         ff8000 = Legendary
--   e6cc80 = Artifact
--
-- ICON ID REFERENCE:
--   0 = Chat bubble       1 = Vendor bag        2 = Taxi/Flightpath
--   3 = Trainer book      4 = Cog/Gear          5 = Cog/Gear (alt)
--   6 = Money bag         7 = Talk bubble       9 = Crossed swords
--   10 = Yellow dot
-- ============================================================================
