-- ============================================================================
-- STAFF RBAC PERMISSIONS
-- Custom permission setup for staff ranks
-- ============================================================================
--
-- TrinityCore Security Levels:
--   0 = SEC_PLAYER      - Regular players
--   1 = SEC_MODERATOR   - Trial GM (limited GM powers)
--   2 = SEC_GAMEMASTER  - Gamemaster (standard GM powers)
--   3 = SEC_ADMINISTRATOR - Admin / Senior GM (full server control)
--   4 = SEC_CONSOLE     - Owner (console-level access)
--
-- Default Permission Groups:
--   195 = Player commands
--   194 = Moderator commands (includes 195)
--   193 = Gamemaster commands (includes 194)
--   192 = Administrator commands (includes 193)
--
-- ============================================================================

-- ============================================================================
-- SETUP DEFAULT PERMISSIONS FOR EACH SECURITY LEVEL
-- ============================================================================

-- Ensure default permissions are set correctly
DELETE FROM `rbac_default_permissions` WHERE `secId` IN (0, 1, 2, 3, 4);
INSERT INTO `rbac_default_permissions` (`secId`, `permissionId`, `realmId`) VALUES
(0, 195, -1),  -- Players get basic commands
(1, 194, -1),  -- Trial GM (Moderator) gets moderator commands
(2, 193, -1),  -- Gamemaster gets GM commands
(3, 192, -1),  -- Admin gets administrator commands
(4, 192, -1);  -- Owner (Console) gets administrator commands

-- ============================================================================
-- TRIAL GM (Security Level 1) - LIMITED POWERS
-- Can: Kick, mute, teleport to players, whisper, announce
-- Cannot: Ban, spawn items, modify players, use GM mode
-- ============================================================================

-- Grant specific permissions to Trial GMs (Moderator level)
-- These are already included in permission group 194, but you can customize

-- ============================================================================
-- GAMEMASTER (Security Level 2) - STANDARD GM POWERS
-- Can: Everything Trial GM can + ban, GM mode, teleport, spawn basic items
-- Cannot: Server commands, reload, account management
-- ============================================================================

-- Already covered by permission group 193

-- ============================================================================
-- SENIOR GAMEMASTER / ADMIN (Security Level 3) - FULL CONTROL
-- Can: Everything + reload, account management, server commands
-- ============================================================================

-- Already covered by permission group 192

-- ============================================================================
-- OWNER (Security Level 4) - CONSOLE LEVEL
-- Full server access - same as administrator but highest rank
-- ============================================================================

-- Same as Admin (192)

-- ============================================================================
-- CUSTOM PERMISSION EXAMPLES
-- Uncomment and modify as needed
-- ============================================================================

-- Example: Give a specific account (ID 5) additional permissions
-- INSERT INTO `rbac_account_permissions` (`accountId`, `permissionId`, `granted`, `realmId`) VALUES
-- (5, 200, 1, -1);  -- Grant permission 200 to account 5

-- Example: Deny a permission to a specific account
-- INSERT INTO `rbac_account_permissions` (`accountId`, `permissionId`, `granted`, `realmId`) VALUES
-- (10, 201, 0, -1);  -- Deny permission 201 to account 10

-- ============================================================================
-- USEFUL QUERIES
-- ============================================================================

-- View all permissions for a security level:
-- SELECT * FROM vw_rbac WHERE `Security Level` = 2;

-- View permissions for a specific account:
-- SELECT p.id, p.name FROM rbac_permissions p
-- JOIN rbac_account_permissions ap ON p.id = ap.permissionId
-- WHERE ap.accountId = <account_id>;

-- Set an account's security level:
-- UPDATE account SET gmlevel = <level> WHERE id = <account_id>;
-- Or using the realmaccess table:
-- INSERT INTO account_access (id, gmlevel, RealmID) VALUES (<account_id>, <level>, -1)
-- ON DUPLICATE KEY UPDATE gmlevel = <level>;

-- ============================================================================
-- COMMON PERMISSION IDS (for reference)
-- ============================================================================
--
-- Player Commands (Group 195):
--   44 = .help
--   45 = .account
--   46 = .logout
--
-- Moderator Commands (Group 194):
--   200 = .kick
--   201 = .mute
--   202 = .unmute
--   203 = .whispers
--
-- Gamemaster Commands (Group 193):
--   300 = .teleport
--   301 = .appear
--   302 = .summon
--   303 = .gm
--   304 = .additem
--   305 = .bank
--
-- Administrator Commands (Group 192):
--   400 = .ban
--   401 = .unban
--   402 = .reload
--   403 = .server
--   404 = .account create
--
-- For full list, check: SELECT * FROM rbac_permissions ORDER BY id;
-- ============================================================================

-- ============================================================================
-- SET ACCOUNT SECURITY LEVELS
-- ============================================================================

-- Example: Set account 1 as Owner (Security Level 4)
-- DELETE FROM account_access WHERE id = 1;
-- INSERT INTO account_access (id, gmlevel, RealmID) VALUES (1, 4, -1);

-- Example: Set account 2 as Admin (Security Level 3)
-- DELETE FROM account_access WHERE id = 2;
-- INSERT INTO account_access (id, gmlevel, RealmID) VALUES (2, 3, -1);

-- Example: Set account 3 as Gamemaster (Security Level 2)
-- DELETE FROM account_access WHERE id = 3;
-- INSERT INTO account_access (id, gmlevel, RealmID) VALUES (3, 2, -1);

-- Example: Set account 4 as Trial GM (Security Level 1)
-- DELETE FROM account_access WHERE id = 4;
-- INSERT INTO account_access (id, gmlevel, RealmID) VALUES (4, 1, -1);

-- ============================================================================
-- CREATING SENIOR GAMEMASTER RANK
-- Since TrinityCore only has 5 security levels (0-4), Senior GM shares
-- level 3 with Admin. To distinguish them, use the custom_staff_rank_overrides
-- table in the world database.
-- ============================================================================

-- Example: Make account 5 a Senior Gamemaster (uses security level 3 but custom display)
-- Run this on your WORLD database:
-- INSERT INTO custom_staff_rank_overrides (account_id, name, color, badge, badge_color, sort_order)
-- VALUES (5, 'Senior GM', 'ff9900', '[S]', 'ff9900', 3);

-- ============================================================================
