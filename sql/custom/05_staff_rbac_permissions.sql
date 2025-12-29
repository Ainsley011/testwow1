-- ============================================================================
-- STAFF RBAC PERMISSIONS
-- Custom permission setup for staff ranks
-- ============================================================================
--
-- TrinityCore Security Levels:
--   0 = SEC_PLAYER      - Regular players
--   1 = SEC_MODERATOR   - Trial GM
--   2 = SEC_GAMEMASTER  - Gamemaster
--   3 = SEC_ADMINISTRATOR - Admin / Senior GM
--   4 = SEC_CONSOLE     - Owner (FULL ACCESS)
--
-- Default Permission Groups:
--   195 = Player commands
--   194 = Moderator commands (includes 195)
--   193 = Gamemaster commands (includes 194)
--   192 = Administrator commands (includes 193)
--
-- ============================================================================

-- ============================================================================
-- OWNER (Security Level 4) - FULL ACCESS TO EVERYTHING
-- ============================================================================

-- Owner gets the Administrator permission group (which includes everything)
-- Plus we ensure they have console-level access
DELETE FROM `rbac_default_permissions` WHERE `secId` = 4;
INSERT INTO `rbac_default_permissions` (`secId`, `permissionId`, `realmId`) VALUES
(4, 192, -1);  -- Full administrator access

-- ============================================================================
-- TRIAL GM (Security Level 1) - ENHANCED PERMISSIONS
-- Added: .tele, .gm mode commands
-- ============================================================================

-- First, ensure Trial GM has moderator permissions
DELETE FROM `rbac_default_permissions` WHERE `secId` = 1;
INSERT INTO `rbac_default_permissions` (`secId`, `permissionId`, `realmId`) VALUES
(1, 194, -1);  -- Moderator base permissions

-- Grant additional permissions to ALL Trial GMs (Security Level 1)
-- These are added via rbac_linked_permissions to the moderator group (194)

-- GM Mode Commands for Trial GM
INSERT IGNORE INTO `rbac_linked_permissions` (`id`, `linkedId`) VALUES
(194, 371),   -- .gm on/off
(194, 373),   -- .gm fly
(194, 376);   -- .gm visible

-- Teleport Commands for Trial GM
INSERT IGNORE INTO `rbac_linked_permissions` (`id`, `linkedId`) VALUES
(194, 737),   -- .tele (teleport self to location)
(194, 740);   -- .tele name (teleport player to location)

-- ============================================================================
-- ENSURE OTHER SECURITY LEVELS ARE CORRECT
-- ============================================================================

DELETE FROM `rbac_default_permissions` WHERE `secId` IN (0, 2, 3);
INSERT INTO `rbac_default_permissions` (`secId`, `permissionId`, `realmId`) VALUES
(0, 195, -1),  -- Players get basic commands
(2, 193, -1),  -- Gamemaster gets GM commands
(3, 192, -1);  -- Admin gets administrator commands

-- ============================================================================
-- PERMISSION REFERENCE
-- ============================================================================
--
-- GM Mode Commands:
--   371 = RBAC_PERM_COMMAND_GM           (.gm on/off)
--   372 = RBAC_PERM_COMMAND_GM_CHAT      (.gm chat)
--   373 = RBAC_PERM_COMMAND_GM_FLY       (.gm fly)
--   374 = RBAC_PERM_COMMAND_GM_INGAME    (.gm ingame)
--   375 = RBAC_PERM_COMMAND_GM_LIST      (.gm list)
--   376 = RBAC_PERM_COMMAND_GM_VISIBLE   (.gm visible)
--
-- Teleport Commands:
--   737 = RBAC_PERM_COMMAND_TELE         (.tele)
--   738 = RBAC_PERM_COMMAND_TELE_ADD     (.tele add)
--   739 = RBAC_PERM_COMMAND_TELE_DEL     (.tele del)
--   740 = RBAC_PERM_COMMAND_TELE_NAME    (.tele name)
--   741 = RBAC_PERM_COMMAND_TELE_GROUP   (.tele group)
--
-- ============================================================================

-- ============================================================================
-- STAFF PERMISSIONS SUMMARY
-- ============================================================================
--
-- TRIAL GM (Level 1):
--   Base: Moderator commands (.kick, .mute, .unmute, .whispers, .pinfo)
--   Added: .gm on/off, .gm fly, .gm visible
--   Added: .tele, .tele name
--
-- GAMEMASTER (Level 2):
--   Everything Trial GM has +
--   .summon, .appear, .go, .additem, .bank
--   .modify, .aura, .npc, .gobject
--   .ban, .unban
--
-- ADMIN (Level 3):
--   Everything Gamemaster has +
--   .reload, .server, .account create/set
--   Full NPC/Object spawning
--
-- OWNER (Level 4):
--   FULL ACCESS TO ALL COMMANDS
--   Same permission level as Admin but highest staff rank
--
-- ============================================================================

-- ============================================================================
-- SET ACCOUNT SECURITY LEVELS
-- ============================================================================

-- To set an account as Owner:
-- INSERT INTO account_access (id, gmlevel, RealmID) VALUES (<account_id>, 4, -1)
-- ON DUPLICATE KEY UPDATE gmlevel = 4;

-- To set an account as Admin:
-- INSERT INTO account_access (id, gmlevel, RealmID) VALUES (<account_id>, 3, -1)
-- ON DUPLICATE KEY UPDATE gmlevel = 3;

-- To set an account as Gamemaster:
-- INSERT INTO account_access (id, gmlevel, RealmID) VALUES (<account_id>, 2, -1)
-- ON DUPLICATE KEY UPDATE gmlevel = 2;

-- To set an account as Trial GM:
-- INSERT INTO account_access (id, gmlevel, RealmID) VALUES (<account_id>, 1, -1)
-- ON DUPLICATE KEY UPDATE gmlevel = 1;

-- ============================================================================
-- CREATING SENIOR GAMEMASTER
-- Since TrinityCore only has 5 security levels (0-4), Senior GM shares
-- level 3 with Admin. Use custom_staff_rank_overrides for display name.
-- ============================================================================

-- Example: Make account 5 a Senior Gamemaster (uses security level 3)
-- First set their security level:
-- INSERT INTO account_access (id, gmlevel, RealmID) VALUES (5, 3, -1);
--
-- Then set their custom display name (run on WORLD database):
-- INSERT INTO custom_staff_rank_overrides (account_id, name, color, badge, badge_color, sort_order)
-- VALUES (5, 'Senior GM', 'ff9900', '[S]', 'ff9900', 3);

-- ============================================================================
-- GRANT/REVOKE SPECIFIC PERMISSIONS TO INDIVIDUAL ACCOUNTS
-- ============================================================================

-- Grant a specific permission to an account:
-- INSERT INTO rbac_account_permissions (accountId, permissionId, granted, realmId)
-- VALUES (<account_id>, <permission_id>, 1, -1);

-- Revoke/Deny a permission from an account:
-- INSERT INTO rbac_account_permissions (accountId, permissionId, granted, realmId)
-- VALUES (<account_id>, <permission_id>, 0, -1);

-- ============================================================================
