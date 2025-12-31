-- ============================================================================
-- Hot Reload System Tables
-- Run on: characters database
-- ============================================================================

-- Log table for tracking all reload operations
CREATE TABLE IF NOT EXISTS `custom_hot_reload_log` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `table_name` VARCHAR(64) NOT NULL,
    `reload_time` INT UNSIGNED NOT NULL,
    `duration_ms` INT UNSIGNED NOT NULL DEFAULT 0,
    `success` TINYINT(1) NOT NULL DEFAULT 1,
    `reloaded_by` VARCHAR(64) DEFAULT NULL COMMENT 'Account name or CONSOLE',
    PRIMARY KEY (`id`),
    KEY `idx_table_name` (`table_name`),
    KEY `idx_reload_time` (`reload_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Hot reload audit log';

-- ============================================================================
-- Configuration table for reload settings
-- Run on: world database
-- ============================================================================

-- Reload configuration
CREATE TABLE IF NOT EXISTS `custom_hot_reload_config` (
    `table_name` VARCHAR(64) NOT NULL,
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    `min_interval_seconds` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Minimum time between reloads',
    `requires_announce` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Announce reload to players',
    `log_to_db` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Hot reload configuration per table';

-- Default configurations
INSERT INTO `custom_hot_reload_config` (`table_name`, `enabled`, `min_interval_seconds`, `requires_announce`, `log_to_db`) VALUES
('teleport', 1, 0, 0, 1),
('artifact', 1, 0, 0, 1),
('worldchat', 1, 0, 0, 1),
('towerdefense', 1, 0, 1, 1),
('vip', 1, 0, 0, 1),
('mythic', 1, 0, 1, 1),
('titles', 1, 0, 0, 1),
('prestige', 1, 0, 0, 1),
('serverstats', 1, 0, 0, 1),
('changelog', 1, 0, 0, 1),
('stafflog', 1, 0, 0, 1),
('transmog', 1, 0, 0, 1),
('votebuff', 1, 0, 0, 1)
ON DUPLICATE KEY UPDATE `table_name` = VALUES(`table_name`);

-- ============================================================================
-- Scheduled reload support (optional)
-- ============================================================================

CREATE TABLE IF NOT EXISTS `custom_hot_reload_schedule` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `table_name` VARCHAR(64) NOT NULL,
    `cron_expression` VARCHAR(64) NOT NULL COMMENT 'Cron format: min hour day month weekday',
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    `last_run` INT UNSIGNED DEFAULT NULL,
    `next_run` INT UNSIGNED DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_next_run` (`next_run`, `enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Scheduled automatic reloads';

-- Example scheduled reloads (disabled by default)
INSERT INTO `custom_hot_reload_schedule` (`table_name`, `cron_expression`, `enabled`) VALUES
('changelog', '0 * * * *', 0),      -- Every hour
('serverstats', '*/5 * * * *', 0),  -- Every 5 minutes
('mythic', '0 0 * * 3', 0)          -- Every Wednesday at midnight (weekly reset)
ON DUPLICATE KEY UPDATE `id` = `id`;

-- ============================================================================
-- Views for monitoring
-- ============================================================================

-- Recent reload activity
CREATE OR REPLACE VIEW `v_hot_reload_recent` AS
SELECT
    `table_name`,
    FROM_UNIXTIME(`reload_time`) AS `reload_datetime`,
    `duration_ms`,
    IF(`success`, 'Success', 'Failed') AS `status`,
    `reloaded_by`
FROM `custom_hot_reload_log`
ORDER BY `reload_time` DESC
LIMIT 100;

-- Reload statistics per table
CREATE OR REPLACE VIEW `v_hot_reload_stats` AS
SELECT
    `table_name`,
    COUNT(*) AS `total_reloads`,
    SUM(IF(`success`, 1, 0)) AS `successful`,
    SUM(IF(`success`, 0, 1)) AS `failed`,
    AVG(`duration_ms`) AS `avg_duration_ms`,
    MAX(`duration_ms`) AS `max_duration_ms`,
    FROM_UNIXTIME(MAX(`reload_time`)) AS `last_reload`
FROM `custom_hot_reload_log`
GROUP BY `table_name`
ORDER BY `total_reloads` DESC;
