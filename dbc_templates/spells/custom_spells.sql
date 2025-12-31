-- ============================================================================
-- CUSTOM SPELLS - Server-Side Data
-- These override/supplement DBC spell data
-- Run on: world database
-- ============================================================================

-- ============================================================================
-- spell_dbc - Server-side spell definitions (alternative to DBC editing)
-- ============================================================================

-- Custom damage spell
INSERT INTO `spell_dbc` (`Id`, `Dispel`, `Mechanic`, `Attributes`, `AttributesEx`, `AttributesEx2`, `AttributesEx3`, `AttributesEx4`, `AttributesEx5`, `Stances`, `StancesNot`, `Targets`, `CastingTimeIndex`, `AuraInterruptFlags`, `ProcFlags`, `ProcChance`, `ProcCharges`, `MaxLevel`, `BaseLevel`, `SpellLevel`, `DurationIndex`, `PowerType`, `ManaCost`, `ManaCostPerlevel`, `ManaPerSecond`, `ManaPerSecondPerLevel`, `RangeIndex`, `Speed`, `StackAmount`, `EquippedItemClass`, `Effect1`, `Effect2`, `Effect3`, `EffectDieSides1`, `EffectDieSides2`, `EffectDieSides3`, `EffectRealPointsPerLevel1`, `EffectRealPointsPerLevel2`, `EffectRealPointsPerLevel3`, `EffectBasePoints1`, `EffectBasePoints2`, `EffectBasePoints3`, `EffectMechanic1`, `EffectMechanic2`, `EffectMechanic3`, `EffectImplicitTargetA1`, `EffectImplicitTargetA2`, `EffectImplicitTargetA3`, `EffectImplicitTargetB1`, `EffectImplicitTargetB2`, `EffectImplicitTargetB3`, `EffectRadiusIndex1`, `EffectRadiusIndex2`, `EffectRadiusIndex3`, `EffectApplyAuraName1`, `EffectApplyAuraName2`, `EffectApplyAuraName3`, `EffectAmplitude1`, `EffectAmplitude2`, `EffectAmplitude3`, `EffectMiscValue1`, `EffectMiscValue2`, `EffectMiscValue3`, `EffectMiscValueB1`, `EffectMiscValueB2`, `EffectMiscValueB3`, `EffectTriggerSpell1`, `EffectTriggerSpell2`, `EffectTriggerSpell3`, `EffectSpellClassMaskA1`, `EffectSpellClassMaskA2`, `EffectSpellClassMaskA3`, `EffectSpellClassMaskB1`, `EffectSpellClassMaskB2`, `EffectSpellClassMaskB3`, `EffectSpellClassMaskC1`, `EffectSpellClassMaskC2`, `EffectSpellClassMaskC3`, `SpellName`, `MaxTargetLevel`, `SpellFamilyName`, `SpellFamilyFlags1`, `SpellFamilyFlags2`, `SpellFamilyFlags3`, `MaxAffectedTargets`, `DmgClass`, `PreventionType`, `DmgMultiplier1`, `DmgMultiplier2`, `DmgMultiplier3`, `AreaGroupId`, `SchoolMask`) VALUES
(100001, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 101, 0, 0, 1, 1, 0, 0, 100, 0, 0, 0, 1, 0, 0, -1, 2, 0, 0, 50, 0, 0, 5, 0, 0, 499, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Mythic Blast', 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 4),
(100002, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 101, 0, 0, 1, 1, 9, 0, 0, 0, 0, 0, 1, 0, 0, -1, 6, 0, 0, 0, 0, 0, 0, 0, 0, 99, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 29, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Mythic Power', 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1),
(100003, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 14, 0, 0, 101, 0, 0, 1, 1, 0, 0, 150, 0, 0, 0, 1, 0, 0, -1, 10, 0, 0, 100, 0, 0, 10, 0, 0, 499, 0, 0, 0, 0, 0, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Mythic Heal', 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 2);

-- ============================================================================
-- spell_bonus_data - Spell coefficient scaling
-- ============================================================================

INSERT INTO `spell_bonus_data` (`entry`, `direct_bonus`, `dot_bonus`, `ap_bonus`, `ap_dot_bonus`, `comments`) VALUES
(100001, 0.857, 0, 0, 0, 'Mythic Blast - Fire damage'),
(100003, 1.0, 0, 0, 0, 'Mythic Heal - Direct heal'),
(100004, 0, 0.2, 0, 0, 'Mythic Corruption - Shadow DoT');

-- ============================================================================
-- spell_proc_event - Proc spell configuration
-- ============================================================================

INSERT INTO `spell_proc_event` (`entry`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`, `SpellFamilyMask1`, `SpellFamilyMask2`, `procFlags`, `procEx`, `ppmRate`, `CustomChance`, `Cooldown`) VALUES
(100005, 0, 0, 0, 0, 0, 16, 0, 0, 15, 0); -- Mythic Vengeance - 15% on hit

-- ============================================================================
-- spell_script_names - Link spells to custom scripts
-- ============================================================================

INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(100001, 'spell_mythic_blast'),
(100002, 'spell_mythic_power'),
(100003, 'spell_mythic_heal'),
(100004, 'spell_mythic_corruption'),
(100005, 'spell_mythic_vengeance');

-- ============================================================================
-- SPELL EFFECTS REFERENCE
-- ============================================================================
-- Effect Types (common):
-- 2  = SPELL_EFFECT_SCHOOL_DAMAGE
-- 3  = SPELL_EFFECT_DUMMY
-- 6  = SPELL_EFFECT_APPLY_AURA
-- 10 = SPELL_EFFECT_HEAL
-- 18 = SPELL_EFFECT_HEAL_PCT
-- 24 = SPELL_EFFECT_ENERGIZE
-- 27 = SPELL_EFFECT_DISPEL
-- 28 = SPELL_EFFECT_SUMMON
-- 36 = SPELL_EFFECT_LEARN_SPELL
-- 42 = SPELL_EFFECT_TRIGGER_SPELL
-- 64 = SPELL_EFFECT_TRIGGER_SPELL_WITH_VALUE
-- 77 = SPELL_EFFECT_SCRIPT_EFFECT

-- Aura Types (common):
-- 3  = SPELL_AURA_PERIODIC_DAMAGE
-- 4  = SPELL_AURA_DUMMY
-- 8  = SPELL_AURA_PERIODIC_HEAL
-- 13 = SPELL_AURA_MOD_DAMAGE_DONE
-- 22 = SPELL_AURA_MOD_RESISTANCE
-- 29 = SPELL_AURA_MOD_STAT (EffectMiscValue = stat type: 0=str, 1=agi, 2=sta, 3=int, 4=spi, -1=all)
-- 42 = SPELL_AURA_PROC_TRIGGER_SPELL
-- 79 = SPELL_AURA_MOD_DAMAGE_PERCENT_DONE
-- 99 = SPELL_AURA_MOD_ATTACK_POWER
-- 135 = SPELL_AURA_MOD_HEALING_DONE
-- 137 = SPELL_AURA_MOD_TOTAL_STAT_PERCENTAGE

-- School Mask:
-- 1 = Physical, 2 = Holy, 4 = Fire, 8 = Nature, 16 = Frost, 32 = Shadow, 64 = Arcane

-- Duration Index (common):
-- 0 = Instant, 1 = 6sec, 3 = 30sec, 4 = 120sec, 5 = 300sec, 6 = 10min, 7 = 2min
-- 9 = 30min, 21 = Permanent, 27 = 3sec, 28 = 5sec, 35 = 4sec, 39 = 12sec

-- Range Index:
-- 1 = Self, 2 = Touch (5yd), 3 = Short (20yd), 4 = Medium (30yd), 5 = Long (40yd), 6 = Vision (100yd)
