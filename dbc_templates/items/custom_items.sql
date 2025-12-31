-- ============================================================================
-- CUSTOM ITEMS - Server-Side Data (item_template)
-- These define stats, requirements, and behavior
-- Run on: world database
-- ============================================================================

-- ============================================================================
-- ITEM TEMPLATE REFERENCE
-- ============================================================================
-- class: 0=Consumable, 1=Container, 2=Weapon, 4=Armor, 7=Tradeskill, 9=Recipe, 12=Quest, 15=Misc
-- subclass: Varies by class
-- Quality: 0=Poor(gray), 1=Common(white), 2=Uncommon(green), 3=Rare(blue), 4=Epic(purple), 5=Legendary(orange), 6=Artifact(red), 7=Heirloom(gold)
-- BuyPrice/SellPrice: In copper (1g = 10000)
-- InventoryType: 0=Non-equip, 1=Head, 2=Neck, 3=Shoulder, 5=Chest, 6=Waist, 7=Legs, 8=Feet, 9=Wrists, 10=Hands, 11=Finger, 12=Trinket, 13=Weapon, 14=Shield, 16=Back, 17=2H, 21=Main Hand, 22=Off Hand
-- AllowableClass: Bitmask (1=Warrior, 2=Paladin, 4=Hunter, 8=Rogue, 16=Priest, 32=DK, 64=Shaman, 128=Mage, 256=Warlock, 1024=Druid) -1=All
-- AllowableRace: Bitmask, -1=All
-- stat_type: 0=Mana, 1=Health, 3=Agility, 4=Strength, 5=Intellect, 6=Spirit, 7=Stamina, 12=DefenseRating, 13=Dodge, 14=Parry, 15=Block, 16=MeleeHit, 17=RangedHit, 18=SpellHit, 19=MeleeCrit, 20=RangedCrit, 21=SpellCrit, 28=MeleeHaste, 29=RangedHaste, 30=SpellHaste, 31=HitRating, 32=CritRating, 35=Resilience, 36=HasteRating, 37=Expertise, 38=AttackPower, 41=CritMeleeDmg, 43=SpellPower, 44=HealthRegen, 45=SpellPen, 46=BlockValue
-- bonding: 0=None, 1=PickUp, 2=Equip, 3=Use, 4=Quest, 5=QuestItem

-- ============================================================================
-- MYTHIC WEAPONS
-- ============================================================================

-- Mythic Sword (1H) - DPS Melee
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `SoundOverrideSubclass`, `name`, `displayid`, `Quality`, `Flags`, `FlagsExtra`, `BuyCount`, `BuyPrice`, `SellPrice`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `RequiredSkill`, `RequiredSkillRank`, `requiredspell`, `requiredhonorrank`, `RequiredCityRank`, `RequiredReputationFaction`, `RequiredReputationRank`, `maxcount`, `stackable`, `ContainerSlots`, `StatsCount`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `stat_type4`, `stat_value4`, `stat_type5`, `stat_value5`, `stat_type6`, `stat_value6`, `stat_type7`, `stat_value7`, `stat_type8`, `stat_value8`, `stat_type9`, `stat_value9`, `stat_type10`, `stat_value10`, `ScalingStatDistribution`, `ScalingStatValue`, `dmg_min1`, `dmg_max1`, `dmg_type1`, `dmg_min2`, `dmg_max2`, `dmg_type2`, `armor`, `holy_res`, `fire_res`, `nature_res`, `frost_res`, `shadow_res`, `arcane_res`, `delay`, `ammo_type`, `RangedModRange`, `spellid_1`, `spelltrigger_1`, `spellcharges_1`, `spellppmRate_1`, `spellcooldown_1`, `spellcategory_1`, `spellcategorycooldown_1`, `spellid_2`, `spelltrigger_2`, `spellcharges_2`, `spellppmRate_2`, `spellcooldown_2`, `spellcategory_2`, `spellcategorycooldown_2`, `spellid_3`, `spelltrigger_3`, `spellcharges_3`, `spellppmRate_3`, `spellcooldown_3`, `spellcategory_3`, `spellcategorycooldown_3`, `spellid_4`, `spelltrigger_4`, `spellcharges_4`, `spellppmRate_4`, `spellcooldown_4`, `spellcategory_4`, `spellcategorycooldown_4`, `spellid_5`, `spelltrigger_5`, `spellcharges_5`, `spellppmRate_5`, `spellcooldown_5`, `spellcategory_5`, `spellcategorycooldown_5`, `bonding`, `description`, `PageText`, `LanguageID`, `PageMaterial`, `startquest`, `lockid`, `Material`, `sheath`, `RandomProperty`, `RandomSuffix`, `block`, `itemset`, `MaxDurability`, `area`, `Map`, `BagFamily`, `TotemCategory`, `socketColor_1`, `socketContent_1`, `socketColor_2`, `socketContent_2`, `socketColor_3`, `socketContent_3`, `socketBonus`, `GemProperties`, `RequiredDisenchantSkill`, `ArmorDamageModifier`, `duration`, `ItemLimitCategory`, `HolidayId`, `ScriptName`, `DisenchantID`, `FoodType`, `minMoneyLoot`, `maxMoneyLoot`, `flagsCustom`, `VerifiedBuild`) VALUES
(100001, 2, 7, -1, 'Mythic Blade of Fury', 65419, 4, 0, 0, 1, 2500000, 500000, 21, -1, -1, 277, 80, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 5, 4, 75, 7, 100, 32, 50, 36, 45, 38, 120, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 350, 650, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2600, 0, 0, 100005, 1, 0, 0, -1, 0, -1, 0, 0, 0, 0, -1, 0, -1, 0, 0, 0, 0, -1, 0, -1, 0, 0, 0, 0, -1, 0, -1, 0, 0, 0, 0, -1, 0, -1, 1, 'Forged in the heart of a dying star.', 0, 0, 0, 0, 0, 1, 3, 0, 0, 0, 0, 120, 0, 0, 0, 0, 2, 0, 4, 0, 8, 0, 3313, 0, 375, 0, 0, 0, 0, '', 75, 0, 0, 0, 0, 0);

-- Mythic Greatsword (2H) - Melee DPS
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `StatsCount`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `stat_type4`, `stat_value4`, `stat_type5`, `stat_value5`, `dmg_min1`, `dmg_max1`, `dmg_type1`, `delay`, `spellid_1`, `spelltrigger_1`, `bonding`, `description`, `Material`, `sheath`, `MaxDurability`, `socketColor_1`, `socketColor_2`, `socketColor_3`, `socketBonus`) VALUES
(100002, 2, 8, 'Mythic Greatsword of Annihilation', 65420, 4, 17, -1, -1, 277, 80, 5, 4, 150, 7, 180, 32, 90, 36, 80, 38, 200, 700, 1050, 0, 3600, 100005, 1, 1, 'The blade that sundered mountains.', 1, 1, 120, 2, 4, 8, 3313);

-- Mythic Staff (2H Caster)
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `StatsCount`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `stat_type4`, `stat_value4`, `stat_type5`, `stat_value5`, `dmg_min1`, `dmg_max1`, `dmg_type1`, `delay`, `bonding`, `description`, `Material`, `sheath`, `MaxDurability`, `socketColor_1`, `socketColor_2`, `socketColor_3`, `socketBonus`) VALUES
(100003, 2, 10, 'Mythic Staff of Infinite Wisdom', 65421, 4, 17, -1, -1, 277, 80, 5, 5, 180, 7, 150, 43, 550, 30, 80, 21, 60, 150, 280, 0, 2800, 1, 'Contains the knowledge of ages.', 2, 2, 120, 1, 1, 4, 3305);

-- ============================================================================
-- MYTHIC PLATE ARMOR SET
-- ============================================================================

-- Plate Helm
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `StatsCount`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `stat_type4`, `stat_value4`, `armor`, `bonding`, `description`, `Material`, `MaxDurability`, `itemset`, `socketColor_1`, `socketBonus`) VALUES
(100010, 4, 4, 'Mythic Helm of the Conqueror', 65430, 4, 1, 35, -1, 264, 80, 4, 4, 100, 7, 130, 13, 50, 14, 45, 2020, 1, 'Worn by champions who never fell.', 1, 100, 1000, 8, 3312);

-- Plate Shoulders
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `StatsCount`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `stat_type4`, `stat_value4`, `armor`, `bonding`, `description`, `Material`, `MaxDurability`, `itemset`, `socketColor_1`, `socketBonus`) VALUES
(100011, 4, 4, 'Mythic Shoulderplates of the Conqueror', 65431, 4, 3, 35, -1, 264, 80, 4, 4, 85, 7, 110, 13, 45, 38, 80, 1870, 1, 'The weight of victory.', 1, 100, 1000, 4, 3312);

-- Plate Chest
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `StatsCount`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `stat_type4`, `stat_value4`, `armor`, `bonding`, `description`, `Material`, `MaxDurability`, `itemset`, `socketColor_1`, `socketColor_2`, `socketBonus`) VALUES
(100012, 4, 4, 'Mythic Breastplate of the Conqueror', 65432, 4, 5, 35, -1, 264, 80, 4, 4, 120, 7, 160, 13, 60, 14, 55, 2570, 1, 'Impenetrable aegis.', 1, 165, 1000, 2, 4, 3312);

-- Plate Bracers
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `StatsCount`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `armor`, `bonding`, `Material`, `MaxDurability`, `itemset`) VALUES
(100013, 4, 4, 'Mythic Bracers of the Conqueror', 65433, 4, 9, 35, -1, 264, 80, 3, 4, 60, 7, 75, 36, 40, 1120, 1, 1, 55, 1000);

-- Plate Gloves
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `StatsCount`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `stat_type4`, `stat_value4`, `armor`, `bonding`, `Material`, `MaxDurability`, `itemset`, `socketColor_1`, `socketBonus`) VALUES
(100014, 4, 4, 'Mythic Gauntlets of the Conqueror', 65434, 4, 10, 35, -1, 264, 80, 4, 4, 85, 7, 100, 32, 50, 36, 45, 1500, 1, 1, 55, 1000, 8, 3312);

-- Plate Belt
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `StatsCount`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `armor`, `bonding`, `Material`, `MaxDurability`, `itemset`) VALUES
(100015, 4, 4, 'Mythic Girdle of the Conqueror', 65435, 4, 6, 35, -1, 264, 80, 3, 4, 70, 7, 90, 13, 40, 1320, 1, 1, 55, 1000);

-- Plate Legs
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `StatsCount`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `stat_type4`, `stat_value4`, `armor`, `bonding`, `Material`, `MaxDurability`, `itemset`, `socketColor_1`, `socketColor_2`, `socketBonus`) VALUES
(100016, 4, 4, 'Mythic Legplates of the Conqueror', 65436, 4, 7, 35, -1, 264, 80, 4, 4, 110, 7, 140, 13, 55, 14, 50, 2200, 1, 1, 120, 1000, 2, 2, 3312);

-- Plate Boots
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `StatsCount`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `armor`, `bonding`, `Material`, `MaxDurability`, `itemset`) VALUES
(100017, 4, 4, 'Mythic Sabatons of the Conqueror', 65437, 4, 8, 35, -1, 264, 80, 3, 4, 80, 7, 100, 36, 45, 1690, 1, 1, 75, 1000);

-- ============================================================================
-- ITEM SET DEFINITION
-- ============================================================================

INSERT INTO `item_set_names` (`entry`, `name`, `InventoryType`) VALUES
(1000, 'Mythic Conqueror\'s Battlegear', 0);

-- ============================================================================
-- MYTHIC ACCESSORIES
-- ============================================================================

-- Necklace
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `StatsCount`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `bonding`, `description`, `MaxDurability`) VALUES
(100050, 4, 0, 'Mythic Pendant of Power', 65470, 4, 2, -1, -1, 264, 80, 3, 7, 90, 32, 55, 36, 50, 1, 'A gem that pulses with energy.', 0);

-- Ring 1
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `StatsCount`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `bonding`, `MaxDurability`) VALUES
(100051, 4, 0, 'Mythic Band of Destruction', 65471, 4, 11, -1, -1, 264, 80, 3, 38, 100, 32, 50, 31, 40, 1, 0);

-- Ring 2
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `StatsCount`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `bonding`, `MaxDurability`) VALUES
(100052, 4, 0, 'Mythic Circle of Protection', 65472, 4, 11, -1, -1, 264, 80, 3, 7, 80, 13, 45, 14, 40, 1, 0);

-- Trinket 1 - On Use
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `StatsCount`, `stat_type1`, `stat_value1`, `spellid_1`, `spelltrigger_1`, `spellcooldown_1`, `bonding`, `description`, `MaxDurability`) VALUES
(100053, 4, 0, 'Mythic Insignia of Power', 65473, 4, 12, -1, -1, 264, 80, 1, 38, 120, 100002, 0, 120000, 1, 'Use: Increases all stats by 100 for 30 sec. (2 Min Cooldown)', 0);

-- Trinket 2 - Proc
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `StatsCount`, `stat_type1`, `stat_value1`, `spellid_1`, `spelltrigger_1`, `bonding`, `description`, `MaxDurability`) VALUES
(100054, 4, 0, 'Mythic Heart of Fury', 65474, 4, 12, -1, -1, 264, 80, 1, 32, 100, 100005, 1, 1, 'Equip: Chance on hit to deal additional Fire damage.', 0);

-- Cloak
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `AllowableClass`, `AllowableRace`, `ItemLevel`, `RequiredLevel`, `StatsCount`, `stat_type1`, `stat_value1`, `stat_type2`, `stat_value2`, `stat_type3`, `stat_value3`, `armor`, `bonding`, `MaxDurability`) VALUES
(100055, 4, 1, 'Mythic Cloak of Shadows', 65475, 4, 16, -1, -1, 264, 80, 3, 3, 80, 32, 50, 36, 45, 200, 1, 0);

-- ============================================================================
-- CONSUMABLES
-- ============================================================================

-- Mythic Flask
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `BuyPrice`, `SellPrice`, `stackable`, `spellid_1`, `spelltrigger_1`, `spellcharges_1`, `bonding`, `description`, `FoodType`) VALUES
(100100, 0, 3, 'Flask of Mythic Power', 65500, 3, 0, 100000, 25000, 20, 100002, 0, -1, 0, 'Use: Increases all stats by 100 for 30 min.', 0);

-- Mythic Potion
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `BuyPrice`, `SellPrice`, `stackable`, `spellid_1`, `spelltrigger_1`, `spellcooldown_1`, `spellcategory_1`, `bonding`, `description`) VALUES
(100101, 0, 1, 'Potion of Mythic Healing', 65501, 2, 0, 10000, 2500, 20, 100003, 0, 60000, 4, 0, 'Use: Restores health. (1 Min Cooldown)');

-- Mythic Food
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `BuyPrice`, `SellPrice`, `stackable`, `spellid_1`, `spelltrigger_1`, `bonding`, `description`, `FoodType`) VALUES
(100102, 0, 5, 'Mythic Feast', 65502, 3, 0, 50000, 12500, 20, 100002, 0, 0, 'Use: Increases all stats by 100 for 1 hour. Must remain seated while eating.', 1);

-- ============================================================================
-- TOKENS / CURRENCIES
-- ============================================================================

-- Mythic Token (for custom currency)
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `Flags`, `stackable`, `bonding`, `description`) VALUES
(100200, 15, 0, 'Mythic Token', 65600, 4, 0, 0, 200, 1, 'Used to purchase mythic gear from special vendors.');

-- Keystone Item
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `InventoryType`, `Flags`, `maxcount`, `stackable`, `bonding`, `description`) VALUES
(100201, 15, 0, 'Mythic Keystone', 65601, 4, 0, 64, 1, 1, 1, 'A mystical key that unlocks mythic dungeon challenges.');
