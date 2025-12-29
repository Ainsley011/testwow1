-- Custom Loot Logging System
-- Creates a table to track all auto-loot distributions for GM review

DROP TABLE IF EXISTS `custom_loot_log`;
CREATE TABLE `custom_loot_log` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `player_guid` INT UNSIGNED NOT NULL,
    `player_name` VARCHAR(50) NOT NULL,
    `item_entry` INT UNSIGNED NOT NULL,
    `item_name` VARCHAR(255) NOT NULL,
    `item_count` INT UNSIGNED NOT NULL DEFAULT 1,
    `source_type` ENUM('creature', 'gameobject', 'mail', 'quest') NOT NULL DEFAULT 'creature',
    `source_entry` INT UNSIGNED NOT NULL DEFAULT 0,
    `source_name` VARCHAR(255) DEFAULT NULL,
    `map_id` INT UNSIGNED NOT NULL DEFAULT 0,
    `zone_id` INT UNSIGNED NOT NULL DEFAULT 0,
    `pos_x` FLOAT NOT NULL DEFAULT 0,
    `pos_y` FLOAT NOT NULL DEFAULT 0,
    `pos_z` FLOAT NOT NULL DEFAULT 0,
    `group_size` TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `gold_received` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Gold in copper',
    PRIMARY KEY (`id`),
    INDEX `idx_player_guid` (`player_guid`),
    INDEX `idx_player_name` (`player_name`),
    INDEX `idx_item_entry` (`item_entry`),
    INDEX `idx_timestamp` (`timestamp`),
    INDEX `idx_source` (`source_type`, `source_entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Custom auto-loot logging for GM review';

-- View for easy querying of recent loot
CREATE OR REPLACE VIEW `v_recent_loot` AS
SELECT
    l.id,
    l.timestamp,
    l.player_name,
    l.item_name,
    l.item_count,
    l.source_type,
    l.source_name,
    l.gold_received / 10000 AS gold,
    l.group_size
FROM custom_loot_log l
ORDER BY l.timestamp DESC
LIMIT 1000;

-- Stored procedure to query player loot history
DELIMITER //
CREATE PROCEDURE `sp_player_loot_history`(IN p_player_name VARCHAR(50), IN p_days INT)
BEGIN
    SELECT
        timestamp,
        item_name,
        item_count,
        source_name,
        gold_received / 10000 AS gold
    FROM custom_loot_log
    WHERE player_name = p_player_name
      AND timestamp >= DATE_SUB(NOW(), INTERVAL p_days DAY)
    ORDER BY timestamp DESC;
END //
DELIMITER ;

-- Stored procedure to find suspicious loot patterns (anti-cheat)
DELIMITER //
CREATE PROCEDURE `sp_suspicious_loot`(IN p_hours INT, IN p_threshold INT)
BEGIN
    SELECT
        player_name,
        item_name,
        COUNT(*) as loot_count,
        MIN(timestamp) as first_loot,
        MAX(timestamp) as last_loot
    FROM custom_loot_log
    WHERE timestamp >= DATE_SUB(NOW(), INTERVAL p_hours HOUR)
    GROUP BY player_guid, item_entry
    HAVING loot_count >= p_threshold
    ORDER BY loot_count DESC;
END //
DELIMITER ;
