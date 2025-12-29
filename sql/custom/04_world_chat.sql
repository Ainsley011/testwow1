-- ============================================================================
-- WORLD CHAT SYSTEM WITH PLAYED TIME RANKS & STAFF RANKS
-- Customizable global chat with player ranks and staff ranks
-- ============================================================================

-- ============================================================================
-- WORLD CHAT SETTINGS TABLE
-- ============================================================================

DROP TABLE IF EXISTS `custom_world_chat_settings`;
CREATE TABLE `custom_world_chat_settings` (
    `setting_name` VARCHAR(50) NOT NULL,
    `setting_value` VARCHAR(255) NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (`setting_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='World chat configuration';

INSERT INTO `custom_world_chat_settings` (`setting_name`, `setting_value`, `description`) VALUES
('enabled', '1', 'Enable/disable world chat (0=off, 1=on)'),
('min_level', '1', 'Minimum player level to use world chat'),
('cooldown', '5', 'Cooldown between messages in seconds'),
('prefix', '[World]', 'Chat prefix shown before rank'),
('prefix_color', 'ff8000', 'Color of the [World] prefix'),
('show_class_color', '1', 'Use class colors for player names (0=off, 1=on)'),
('announce_join', '0', 'Announce when players join world chat'),
('profanity_filter', '0', 'Enable basic profanity filter'),
('max_message_length', '255', 'Maximum message length');

-- ============================================================================
-- STAFF RANKS TABLE (based on account security level)
-- Maps TrinityCore security levels to custom staff ranks
-- ============================================================================

DROP TABLE IF EXISTS `custom_staff_ranks`;
CREATE TABLE `custom_staff_ranks` (
    `security_level` TINYINT UNSIGNED NOT NULL COMMENT 'Account security level (1-4)',
    `name` VARCHAR(50) NOT NULL COMMENT 'Staff rank display name',
    `color` VARCHAR(8) NOT NULL DEFAULT 'ff0000' COMMENT 'Rank name color (RRGGBB)',
    `badge` VARCHAR(20) DEFAULT NULL COMMENT 'Badge/icon shown before name',
    `badge_color` VARCHAR(8) DEFAULT NULL COMMENT 'Badge color',
    `chat_color` VARCHAR(8) NOT NULL DEFAULT 'ffffff' COMMENT 'Message text color',
    `can_use_colors` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Can use color codes in messages',
    `bypass_cooldown` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Bypass chat cooldown',
    `bypass_mute` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Bypass account mute for world chat',
    `sort_order` TINYINT NOT NULL DEFAULT 0 COMMENT 'Display order (higher = more important)',
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`security_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Staff ranks for world chat display';

-- TrinityCore Security Levels:
-- 0 = SEC_PLAYER (no entry needed - uses player ranks)
-- 1 = SEC_MODERATOR -> Trial GM
-- 2 = SEC_GAMEMASTER -> Gamemaster
-- 3 = SEC_ADMINISTRATOR -> Admin (also Senior GM with custom flag)
-- 4 = SEC_CONSOLE -> Owner

INSERT INTO `custom_staff_ranks`
(`security_level`, `name`, `color`, `badge`, `badge_color`, `chat_color`, `can_use_colors`, `bypass_cooldown`, `bypass_mute`, `sort_order`) VALUES
-- Trial GM (Security Level 1)
(1, 'Trial GM', '00ff96', '[T]', '00ff96', 'ffffff', 1, 1, 0, 1),
-- Gamemaster (Security Level 2)
(2, 'Gamemaster', '00ccff', '[GM]', '00ccff', 'ffffff', 1, 1, 0, 2),
-- Senior Gamemaster (Security Level 3 - shares with Admin but lower sort_order)
-- Note: For Senior GM, use custom_staff_rank_overrides table per account
-- Admin (Security Level 3)
(3, 'Admin', 'ff3333', '[A]', 'ff3333', 'ffffff', 1, 1, 1, 4),
-- Owner (Security Level 4 / Console)
(4, 'Owner', 'e6cc80', '★', 'e6cc80', 'ffffff', 1, 1, 1, 5);

-- ============================================================================
-- STAFF RANK OVERRIDES (per-account custom rank)
-- Allows assigning Senior GM or custom titles to specific accounts
-- ============================================================================

DROP TABLE IF EXISTS `custom_staff_rank_overrides`;
CREATE TABLE `custom_staff_rank_overrides` (
    `account_id` INT UNSIGNED NOT NULL,
    `name` VARCHAR(50) NOT NULL COMMENT 'Custom rank display name',
    `color` VARCHAR(8) NOT NULL COMMENT 'Rank name color (RRGGBB)',
    `badge` VARCHAR(20) DEFAULT NULL COMMENT 'Badge/icon',
    `badge_color` VARCHAR(8) DEFAULT NULL COMMENT 'Badge color',
    `sort_order` TINYINT NOT NULL DEFAULT 0,
    PRIMARY KEY (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Per-account staff rank overrides';

-- Example: To make account ID 5 a Senior Gamemaster:
-- INSERT INTO custom_staff_rank_overrides (account_id, name, color, badge, badge_color, sort_order)
-- VALUES (5, 'Senior GM', 'ff9900', '[S]', 'ff9900', 3);

-- ============================================================================
-- PLAYER RANKS TABLE (based on /played time)
-- 10 ranks for regular players
-- ============================================================================

DROP TABLE IF EXISTS `custom_world_chat_ranks`;
CREATE TABLE `custom_world_chat_ranks` (
    `rank_id` TINYINT UNSIGNED NOT NULL,
    `name` VARCHAR(50) NOT NULL COMMENT 'Rank display name',
    `color` VARCHAR(8) NOT NULL DEFAULT 'ffffff' COMMENT 'Rank name color (RRGGBB)',
    `badge` VARCHAR(20) DEFAULT NULL COMMENT 'Optional badge/icon text',
    `badge_color` VARCHAR(8) DEFAULT NULL COMMENT 'Badge color',
    `min_played_time` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Minimum /played time in seconds',
    `chat_color` VARCHAR(8) NOT NULL DEFAULT 'ffffff' COMMENT 'Message text color',
    `can_use_colors` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Can use color codes in messages',
    `cooldown_modifier` FLOAT NOT NULL DEFAULT 1.0 COMMENT 'Cooldown multiplier (0.5 = half cooldown)',
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`rank_id`),
    INDEX `idx_played_time` (`min_played_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='World chat ranks based on played time';

-- ============================================================================
-- DEFAULT PLAYER RANKS (10 levels)
-- ============================================================================

INSERT INTO `custom_world_chat_ranks`
(`rank_id`, `name`, `color`, `badge`, `badge_color`, `min_played_time`, `chat_color`, `can_use_colors`, `cooldown_modifier`) VALUES
-- Rank 0: Newcomer (0 - 1 hour)
(0, 'Newcomer', '9d9d9d', NULL, NULL, 0, 'ffffff', 0, 1.5),
-- Rank 1: Rookie (1 hour - 6 hours)
(1, 'Rookie', 'ffffff', NULL, NULL, 3600, 'ffffff', 0, 1.2),
-- Rank 2: Regular (6 hours - 1 day)
(2, 'Regular', '1eff00', NULL, NULL, 21600, 'ffffff', 0, 1.0),
-- Rank 3: Dedicated (1 day - 3 days)
(3, 'Dedicated', '1eff00', '★', '1eff00', 86400, 'ffffff', 0, 1.0),
-- Rank 4: Veteran (3 days - 7 days)
(4, 'Veteran', '0070dd', '★', '0070dd', 259200, 'ffffff', 0, 0.9),
-- Rank 5: Expert (7 days - 14 days)
(5, 'Expert', '0070dd', '★★', '0070dd', 604800, 'ffffff', 1, 0.8),
-- Rank 6: Elite (14 days - 30 days)
(6, 'Elite', 'a335ee', '★★', 'a335ee', 1209600, 'ffffff', 1, 0.7),
-- Rank 7: Champion (30 days - 60 days)
(7, 'Champion', 'a335ee', '★★★', 'a335ee', 2592000, 'ffffff', 1, 0.6),
-- Rank 8: Legend (60 days - 120 days)
(8, 'Legend', 'ff8000', '★★★', 'ff8000', 5184000, 'ffffff', 1, 0.5),
-- Rank 9: Immortal (120+ days)
(9, 'Immortal', 'e6cc80', '✦✦✦', 'e6cc80', 10368000, 'ffffff', 1, 0.3);

-- ============================================================================
-- PLAYER WORLD CHAT DATA (opt-out tracking)
-- Note: Mutes now use the standard account mute system
-- ============================================================================

DROP TABLE IF EXISTS `character_world_chat`;
CREATE TABLE `character_world_chat` (
    `guid` INT UNSIGNED NOT NULL,
    `enabled` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Player has world chat enabled',
    `total_messages` INT UNSIGNED NOT NULL DEFAULT 0,
    `last_message_time` INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Player world chat preferences';

-- ============================================================================
-- WORLD CHAT HISTORY/LOG (for moderation)
-- ============================================================================

DROP TABLE IF EXISTS `custom_world_chat_log`;
CREATE TABLE `custom_world_chat_log` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `account_id` INT UNSIGNED NOT NULL,
    `player_guid` INT UNSIGNED NOT NULL,
    `player_name` VARCHAR(50) NOT NULL,
    `is_staff` TINYINT(1) NOT NULL DEFAULT 0,
    `rank_name` VARCHAR(50) NOT NULL,
    `message` TEXT NOT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_account` (`account_id`),
    INDEX `idx_player` (`player_guid`),
    INDEX `idx_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='World chat message log';

-- ============================================================================
-- HELPFUL QUERIES
-- ============================================================================

-- View all staff ranks:
-- SELECT * FROM custom_staff_ranks ORDER BY sort_order DESC;

-- Make an account a Senior Gamemaster:
-- INSERT INTO custom_staff_rank_overrides (account_id, name, color, badge, badge_color, sort_order)
-- VALUES (<account_id>, 'Senior GM', 'ff9900', '[S]', 'ff9900', 3);

-- View chat history for moderation:
-- SELECT * FROM custom_world_chat_log ORDER BY timestamp DESC LIMIT 100;

-- ============================================================================
-- COLOR REFERENCE
-- ============================================================================
--
-- Staff Colors:
--   00ff96 = Trial GM (Druid green)
--   00ccff = Gamemaster (Cyan)
--   ff9900 = Senior GM (Orange)
--   ff3333 = Admin (Red)
--   e6cc80 = Owner (Gold/Artifact)
--
-- Item Quality Colors:
--   9d9d9d = Poor (gray)
--   ffffff = Common (white)
--   1eff00 = Uncommon (green)
--   0070dd = Rare (blue)
--   a335ee = Epic (purple)
--   ff8000 = Legendary (orange)
--   e6cc80 = Artifact (light gold)
--
-- ============================================================================
