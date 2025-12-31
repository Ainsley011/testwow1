-- ============================================================================
-- CUSTOM ITEM SETS - Set Bonuses
-- Run on: world database
-- ============================================================================

-- ============================================================================
-- ITEM SET DEFINITIONS
-- ============================================================================

-- Mythic Conqueror's Battlegear (Plate DPS/Tank)
DELETE FROM `item_set_names` WHERE `entry` = 1000;
INSERT INTO `item_set_names` (`entry`, `name`, `InventoryType`) VALUES
(1000, 'Mythic Conqueror\'s Battlegear', 0);

-- Mythic Slayer's Vestments (Leather DPS)
INSERT INTO `item_set_names` (`entry`, `name`, `InventoryType`) VALUES
(1001, 'Mythic Slayer\'s Vestments', 0);

-- Mythic Archmage's Regalia (Cloth Caster)
INSERT INTO `item_set_names` (`entry`, `name`, `InventoryType`) VALUES
(1002, 'Mythic Archmage\'s Regalia', 0);

-- Mythic Beastlord's Armor (Mail Hunter)
INSERT INTO `item_set_names` (`entry`, `name`, `InventoryType`) VALUES
(1003, 'Mythic Beastlord\'s Armor', 0);

-- ============================================================================
-- SPELL_ITEM_ENCHANTMENT for Set Bonuses
-- These define what the set bonuses actually do
-- ============================================================================

-- Set Bonus Auras (create spells for these)
-- 2pc: +100 Strength
-- 4pc: +5% damage
-- These need corresponding entries in Spell.dbc or spell_dbc

-- ============================================================================
-- Link items to sets
-- Update items to belong to a set
-- ============================================================================

UPDATE `item_template` SET `itemset` = 1000 WHERE `entry` IN (100010, 100011, 100012, 100013, 100014, 100015, 100016, 100017);

-- ============================================================================
-- ITEM SET SPELLS (world_database)
-- Note: item_set_spell doesn't exist in 3.3.5, bonuses are in DBC
-- Use this for reference/documentation
-- ============================================================================

-- For server-side set bonuses, create a custom table:
CREATE TABLE IF NOT EXISTS `custom_item_set_bonus` (
    `set_id` INT UNSIGNED NOT NULL,
    `required_items` TINYINT UNSIGNED NOT NULL COMMENT 'Number of items needed',
    `spell_id` INT UNSIGNED NOT NULL COMMENT 'Spell applied when bonus active',
    `description` VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (`set_id`, `required_items`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `custom_item_set_bonus` (`set_id`, `required_items`, `spell_id`, `description`) VALUES
-- Mythic Conqueror's Battlegear
(1000, 2, 100010, '+100 Strength'),
(1000, 4, 100011, '+5% Physical damage'),
-- Mythic Slayer's Vestments
(1001, 2, 100012, '+100 Agility'),
(1001, 4, 100013, '+5% Attack Power'),
-- Mythic Archmage's Regalia
(1002, 2, 100014, '+100 Intellect'),
(1002, 4, 100015, '+5% Spell Power'),
-- Mythic Beastlord's Armor
(1003, 2, 100016, '+100 Agility'),
(1003, 4, 100017, '+10% Pet damage');

-- ============================================================================
-- SET BONUS SPELLS
-- These are passive auras applied when wearing enough pieces
-- ============================================================================

INSERT INTO `spell_dbc` (`Id`, `Attributes`, `AttributesEx`, `CastingTimeIndex`, `DurationIndex`, `Effect1`, `EffectApplyAuraName1`, `EffectBasePoints1`, `EffectMiscValue1`, `EffectImplicitTargetA1`, `SpellName`) VALUES
-- Conqueror 2pc: +100 Strength
(100010, 0x10000000, 0x400, 1, 21, 6, 29, 99, 4, 1, 'Conqueror 2pc Bonus'),
-- Conqueror 4pc: +5% Physical damage
(100011, 0x10000000, 0x400, 1, 21, 6, 79, 4, 1, 1, 'Conqueror 4pc Bonus'),
-- Slayer 2pc: +100 Agility
(100012, 0x10000000, 0x400, 1, 21, 6, 29, 99, 3, 1, 'Slayer 2pc Bonus'),
-- Slayer 4pc: +5% Attack Power
(100013, 0x10000000, 0x400, 1, 21, 6, 99, 4, 0, 1, 'Slayer 4pc Bonus'),
-- Archmage 2pc: +100 Intellect
(100014, 0x10000000, 0x400, 1, 21, 6, 29, 99, 5, 1, 'Archmage 2pc Bonus'),
-- Archmage 4pc: +5% Spell Power
(100015, 0x10000000, 0x400, 1, 21, 6, 13, 4, 126, 1, 'Archmage 4pc Bonus'),
-- Beastlord 2pc: +100 Agility
(100016, 0x10000000, 0x400, 1, 21, 6, 29, 99, 3, 1, 'Beastlord 2pc Bonus'),
-- Beastlord 4pc: +10% Pet damage (dummy, needs script)
(100017, 0x10000000, 0x400, 1, 21, 6, 4, 9, 0, 1, 'Beastlord 4pc Bonus');
