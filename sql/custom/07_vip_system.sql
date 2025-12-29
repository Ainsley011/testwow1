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
-- GM COMMANDS FOR VIP MANAGEMENT
-- .vip add <player> [days] - Add VIP status (0 = permanent)
-- .vip remove <player> - Remove VIP status
-- .vip check <player> - Check VIP status
-- .vip list - List all VIPs
-- ============================================================================

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
