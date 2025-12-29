-- ============================================================================
-- WORLD CHAT SYSTEM WITH PLAYED TIME RANKS
-- Customizable global chat with 10 ranks based on /played time
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
('gm_badge', '[GM]', 'Badge shown for GM accounts'),
('gm_badge_color', 'ff0000', 'Color of GM badge'),
('show_class_color', '1', 'Use class colors for player names (0=off, 1=on)'),
('announce_join', '0', 'Announce when players join world chat'),
('profanity_filter', '0', 'Enable basic profanity filter'),
('max_message_length', '255', 'Maximum message length');

-- ============================================================================
-- WORLD CHAT RANKS TABLE
-- 10 ranks based on /played time (in seconds)
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
-- DEFAULT RANKS (10 levels)
-- Time values in seconds:
--   1 hour = 3600, 1 day = 86400, 1 week = 604800
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
-- PLAYER WORLD CHAT DATA (opt-out, mutes, etc.)
-- ============================================================================

DROP TABLE IF EXISTS `character_world_chat`;
CREATE TABLE `character_world_chat` (
    `guid` INT UNSIGNED NOT NULL,
    `enabled` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Player has world chat enabled',
    `muted_until` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Unix timestamp when mute expires',
    `mute_reason` VARCHAR(255) DEFAULT NULL,
    `total_messages` INT UNSIGNED NOT NULL DEFAULT 0,
    `last_message_time` INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Player world chat preferences';

-- ============================================================================
-- WORLD CHAT HISTORY/LOG (optional, for moderation)
-- ============================================================================

DROP TABLE IF EXISTS `custom_world_chat_log`;
CREATE TABLE `custom_world_chat_log` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `player_guid` INT UNSIGNED NOT NULL,
    `player_name` VARCHAR(50) NOT NULL,
    `rank_id` TINYINT UNSIGNED NOT NULL,
    `message` TEXT NOT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_player` (`player_guid`),
    INDEX `idx_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='World chat message log';

-- ============================================================================
-- PLAYED TIME TO READABLE FORMAT
-- ============================================================================
--
-- Quick reference:
--   1 hour    = 3,600 seconds
--   6 hours   = 21,600 seconds
--   12 hours  = 43,200 seconds
--   1 day     = 86,400 seconds
--   3 days    = 259,200 seconds
--   7 days    = 604,800 seconds
--   14 days   = 1,209,600 seconds
--   30 days   = 2,592,000 seconds
--   60 days   = 5,184,000 seconds
--   90 days   = 7,776,000 seconds
--   120 days  = 10,368,000 seconds
--   180 days  = 15,552,000 seconds
--   365 days  = 31,536,000 seconds
--
-- ============================================================================

-- ============================================================================
-- HELPFUL QUERIES
-- ============================================================================

-- View all ranks with readable time:
-- SELECT rank_id, name, color, badge,
--        CONCAT(FLOOR(min_played_time/86400), 'd ',
--               FLOOR((min_played_time%86400)/3600), 'h') as required_time
-- FROM custom_world_chat_ranks ORDER BY rank_id;

-- Change a rank's required time to 2 days:
-- UPDATE custom_world_chat_ranks SET min_played_time = 172800 WHERE rank_id = 3;

-- Add a new custom badge:
-- UPDATE custom_world_chat_ranks SET badge = '🔥', badge_color = 'ff4500' WHERE rank_id = 9;

-- Mute a player for 1 hour:
-- INSERT INTO character_world_chat (guid, muted_until, mute_reason)
-- VALUES (<guid>, UNIX_TIMESTAMP() + 3600, 'Spam')
-- ON DUPLICATE KEY UPDATE muted_until = UNIX_TIMESTAMP() + 3600, mute_reason = 'Spam';

-- View chat history for moderation:
-- SELECT * FROM custom_world_chat_log ORDER BY timestamp DESC LIMIT 100;

-- ============================================================================
-- COLOR REFERENCE
-- ============================================================================
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
-- Class Colors:
--   c79c6e = Warrior
--   f58cba = Paladin
--   abd473 = Hunter
--   fff569 = Rogue
--   ffffff = Priest
--   c41f3b = Death Knight
--   0070de = Shaman
--   69ccf0 = Mage
--   9482c9 = Warlock
--   00ff96 = Druid
--
-- ============================================================================
