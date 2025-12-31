# DBC Templates for Custom Content

This directory contains CSV templates and SQL files for creating custom game content.

## Directory Structure

```
dbc_templates/
├── spells/
│   ├── Spell.dbc.csv       # Custom spell definitions
│   └── custom_spells.sql   # Server-side spell data
├── items/
│   ├── Item.dbc.csv        # Item DBC entries
│   ├── custom_items.sql    # Item stats and properties
│   └── item_sets.sql       # Set bonuses
├── talents/
│   └── Talent.dbc.csv      # Custom talents
├── skills/
│   └── (skill templates)
└── README.md
```

## Workflow

### Method 1: DBC Editing (Requires Client Patch)

1. Export existing DBC to CSV using tools
2. Edit CSV files with custom entries (use high IDs: 100000+)
3. Convert CSV back to DBC
4. Pack into patch-X.MPQ
5. Players install patch

**Tools Needed:**
- MPQ Editor (Ladik's)
- WDBX Editor or MyDBCEditor
- BLP Converter (for textures)

### Method 2: Server-Side Only (No Client Patch)

Many things can be done using only SQL:

| Content Type | Server Table | Notes |
|--------------|--------------|-------|
| Item stats | `item_template` | Uses existing visuals |
| Spell effects | `spell_dbc` | Uses existing animations |
| Creature stats | `creature_template` | Uses existing models |
| Quests | `quest_template` | Full quest creation |
| Loot tables | `*_loot_template` | Drop rates |

## ID Ranges

To avoid conflicts with Blizzard content:

| Type | Safe Range |
|------|------------|
| Spells | 100000 - 199999 |
| Items | 100000 - 199999 |
| Creatures | 100000 - 199999 |
| GameObjects | 500000 - 599999 |
| Quests | 100000 - 199999 |
| Talents | 3000+ |
| Item Sets | 1000+ |

## DBC File Reference

### Core Files

| DBC File | Purpose |
|----------|---------|
| Spell.dbc | All spell definitions |
| Item.dbc | Basic item properties |
| ItemDisplayInfo.dbc | Item visuals/models |
| SpellVisual.dbc | Spell visual effects |
| SpellIcon.dbc | Spell icons |
| Talent.dbc | Talent definitions |
| TalentTab.dbc | Talent tree tabs |
| SkillLine.dbc | Skill definitions |
| SkillLineAbility.dbc | Skills to spells |

### Spell Effect Types

| ID | Name | Description |
|----|------|-------------|
| 2 | SCHOOL_DAMAGE | Direct damage |
| 3 | DUMMY | Script hook |
| 6 | APPLY_AURA | Apply buff/debuff |
| 10 | HEAL | Direct heal |
| 18 | HEAL_PCT | Percent heal |
| 24 | ENERGIZE | Restore mana/energy |
| 28 | SUMMON | Summon creature |
| 36 | LEARN_SPELL | Teach spell |
| 42 | TRIGGER_SPELL | Cast another spell |
| 77 | SCRIPT_EFFECT | Custom script |

### Aura Types

| ID | Name | Description |
|----|------|-------------|
| 3 | PERIODIC_DAMAGE | DoT |
| 4 | DUMMY | Script hook |
| 8 | PERIODIC_HEAL | HoT |
| 13 | MOD_DAMAGE_DONE | Flat damage bonus |
| 22 | MOD_RESISTANCE | Resistance buff |
| 29 | MOD_STAT | Stat increase |
| 42 | PROC_TRIGGER_SPELL | Proc chance |
| 79 | MOD_DAMAGE_PERCENT_DONE | % damage bonus |
| 99 | MOD_ATTACK_POWER | AP buff |
| 135 | MOD_HEALING_DONE | Healing buff |
| 137 | MOD_TOTAL_STAT_PERCENTAGE | % stat bonus |

### Stat Types (for items)

| ID | Stat |
|----|------|
| 3 | Agility |
| 4 | Strength |
| 5 | Intellect |
| 6 | Spirit |
| 7 | Stamina |
| 12 | Defense Rating |
| 13 | Dodge Rating |
| 14 | Parry Rating |
| 31 | Hit Rating |
| 32 | Crit Rating |
| 35 | Resilience |
| 36 | Haste Rating |
| 37 | Expertise |
| 38 | Attack Power |
| 43 | Spell Power |
| 45 | Spell Penetration |

### School Mask

| Bit | School |
|-----|--------|
| 1 | Physical |
| 2 | Holy |
| 4 | Fire |
| 8 | Nature |
| 16 | Frost |
| 32 | Shadow |
| 64 | Arcane |

### Duration Index

| ID | Duration |
|----|----------|
| 0 | Instant |
| 1 | 6 seconds |
| 3 | 30 seconds |
| 4 | 2 minutes |
| 5 | 5 minutes |
| 6 | 10 minutes |
| 9 | 30 minutes |
| 21 | Permanent |
| 27 | 3 seconds |
| 28 | 5 seconds |
| 35 | 4 seconds |
| 39 | 12 seconds |

### Item Quality

| ID | Quality | Color |
|----|---------|-------|
| 0 | Poor | Gray |
| 1 | Common | White |
| 2 | Uncommon | Green |
| 3 | Rare | Blue |
| 4 | Epic | Purple |
| 5 | Legendary | Orange |
| 6 | Artifact | Red |
| 7 | Heirloom | Gold |

### Inventory Types

| ID | Slot |
|----|------|
| 0 | Non-equip |
| 1 | Head |
| 2 | Neck |
| 3 | Shoulder |
| 4 | Shirt |
| 5 | Chest |
| 6 | Waist |
| 7 | Legs |
| 8 | Feet |
| 9 | Wrists |
| 10 | Hands |
| 11 | Finger |
| 12 | Trinket |
| 13 | One-Hand |
| 14 | Shield |
| 15 | Ranged |
| 16 | Back |
| 17 | Two-Hand |
| 21 | Main Hand |
| 22 | Off Hand |
| 23 | Held |

## Example: Creating a Custom Weapon

### 1. Add to Item.dbc (CSV)
```csv
100001,2,7,-1,1,65419,21,3
```

### 2. Add to item_template (SQL)
```sql
INSERT INTO item_template (entry, class, subclass, name, displayid, Quality,
    InventoryType, ItemLevel, RequiredLevel, dmg_min1, dmg_max1, delay,
    stat_type1, stat_value1, stat_type2, stat_value2) VALUES
(100001, 2, 7, 'Custom Sword', 65419, 4, 21, 277, 80, 350, 650, 2600, 4, 75, 7, 100);
```

### 3. Add on-equip spell (optional)
```sql
UPDATE item_template SET spellid_1 = 100005, spelltrigger_1 = 1 WHERE entry = 100001;
```

## Example: Creating a Custom Spell

### 1. Add to Spell.dbc (CSV) or spell_dbc (SQL)
```sql
INSERT INTO spell_dbc (Id, Effect1, EffectBasePoints1, EffectImplicitTargetA1,
    EffectApplyAuraName1, DurationIndex, SpellName, SchoolMask) VALUES
(100001, 2, 499, 6, 0, 0, 'Mythic Blast', 4);
```

### 2. Add spell coefficient
```sql
INSERT INTO spell_bonus_data (entry, direct_bonus, comments) VALUES
(100001, 0.857, 'Mythic Blast');
```

### 3. Link to script (optional)
```sql
INSERT INTO spell_script_names (spell_id, ScriptName) VALUES
(100001, 'spell_mythic_blast');
```

## Tips

1. **Always backup** before editing DBC files
2. **Use high IDs** (100000+) to avoid conflicts
3. **Test incrementally** - add one thing at a time
4. **Check logs** for errors after loading custom content
5. **Use existing visuals** when possible to avoid client patches
