-- ============================================================================
-- ACCOUNT POINTS SYSTEM
-- Tracks Donation Points and Vote Points per account
-- Used by Magic Stone Account Info tab
-- ============================================================================

-- ============================================================================
-- ACCOUNT POINTS TABLE (Character Database)
-- Stores donation and vote points for each account
-- ============================================================================

DROP TABLE IF EXISTS `account_points`;
CREATE TABLE `account_points` (
    `account_id` INT UNSIGNED NOT NULL,
    `donation_points` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Points from donations',
    `vote_points` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Points from voting',
    `total_donated` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Total amount ever donated (in cents)',
    `total_votes` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Total votes ever cast',
    `last_vote` TIMESTAMP NULL DEFAULT NULL COMMENT 'Last vote timestamp',
    `last_donation` TIMESTAMP NULL DEFAULT NULL COMMENT 'Last donation timestamp',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Account points for donations and voting';

-- ============================================================================
-- ACCOUNT POINTS HISTORY TABLE (Character Database)
-- Logs all point transactions for auditing
-- ============================================================================

DROP TABLE IF EXISTS `account_points_history`;
CREATE TABLE `account_points_history` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `account_id` INT UNSIGNED NOT NULL,
    `point_type` ENUM('donation', 'vote') NOT NULL,
    `amount` INT NOT NULL COMMENT 'Positive = add, Negative = spend',
    `balance_after` INT UNSIGNED NOT NULL COMMENT 'Balance after transaction',
    `reason` VARCHAR(255) DEFAULT NULL COMMENT 'Transaction reason/description',
    `source` VARCHAR(100) DEFAULT NULL COMMENT 'Source (website, ingame, admin, etc.)',
    `admin_id` INT UNSIGNED DEFAULT NULL COMMENT 'Admin who processed (if applicable)',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_account` (`account_id`),
    INDEX `idx_type` (`point_type`),
    INDEX `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Account points transaction history';

-- ============================================================================
-- DONATION PACKAGES TABLE (World Database)
-- Define donation packages that can be purchased
-- ============================================================================

DROP TABLE IF EXISTS `custom_donation_packages`;
CREATE TABLE `custom_donation_packages` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    `price_cents` INT UNSIGNED NOT NULL COMMENT 'Price in cents (USD)',
    `points` INT UNSIGNED NOT NULL COMMENT 'Donation points awarded',
    `bonus_points` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Bonus points (promotions)',
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    `sort_order` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Donation packages available for purchase';

-- Default donation packages
INSERT INTO `custom_donation_packages` (`name`, `description`, `price_cents`, `points`, `bonus_points`, `sort_order`) VALUES
('Starter Pack', '100 Donation Points', 500, 100, 0, 10),
('Bronze Pack', '250 Donation Points + 25 Bonus', 1000, 250, 25, 20),
('Silver Pack', '600 Donation Points + 100 Bonus', 2000, 600, 100, 30),
('Gold Pack', '1500 Donation Points + 300 Bonus', 5000, 1500, 300, 40),
('Platinum Pack', '3500 Donation Points + 1000 Bonus', 10000, 3500, 1000, 50);

-- ============================================================================
-- VOTE SITES TABLE (World Database)
-- Configure voting sites and rewards
-- ============================================================================

DROP TABLE IF EXISTS `custom_vote_sites`;
CREATE TABLE `custom_vote_sites` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `url` VARCHAR(255) NOT NULL COMMENT 'Voting URL',
    `points_per_vote` INT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Points awarded per vote',
    `cooldown_hours` INT UNSIGNED NOT NULL DEFAULT 12 COMMENT 'Hours between votes',
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    `sort_order` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Voting sites configuration';

-- Example vote sites (customize with your own!)
INSERT INTO `custom_vote_sites` (`name`, `url`, `points_per_vote`, `cooldown_hours`, `sort_order`) VALUES
('TopG', 'https://topg.org/vote/YOUR_SERVER_ID', 2, 12, 10),
('Top100Arena', 'https://top100arena.com/vote/YOUR_SERVER_ID', 2, 12, 20),
('Private Server List', 'https://private-servers.com/vote/YOUR_SERVER_ID', 1, 12, 30);

-- ============================================================================
-- HELPFUL PROCEDURES
-- ============================================================================

-- Add points to an account (use negative amount to remove points)
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS `AddAccountPoints`(
    IN p_account_id INT UNSIGNED,
    IN p_point_type VARCHAR(10),
    IN p_amount INT,
    IN p_reason VARCHAR(255),
    IN p_source VARCHAR(100),
    IN p_admin_id INT UNSIGNED
)
BEGIN
    DECLARE v_current_balance INT UNSIGNED DEFAULT 0;
    DECLARE v_new_balance INT UNSIGNED;

    -- Ensure account exists in points table
    INSERT IGNORE INTO account_points (account_id) VALUES (p_account_id);

    -- Get current balance
    IF p_point_type = 'donation' THEN
        SELECT donation_points INTO v_current_balance FROM account_points WHERE account_id = p_account_id;
        SET v_new_balance = GREATEST(0, CAST(v_current_balance AS SIGNED) + p_amount);
        UPDATE account_points SET donation_points = v_new_balance WHERE account_id = p_account_id;
        IF p_amount > 0 THEN
            UPDATE account_points SET last_donation = NOW() WHERE account_id = p_account_id;
        END IF;
    ELSE
        SELECT vote_points INTO v_current_balance FROM account_points WHERE account_id = p_account_id;
        SET v_new_balance = GREATEST(0, CAST(v_current_balance AS SIGNED) + p_amount);
        UPDATE account_points SET vote_points = v_new_balance WHERE account_id = p_account_id;
        IF p_amount > 0 THEN
            UPDATE account_points SET last_vote = NOW(), total_votes = total_votes + 1 WHERE account_id = p_account_id;
        END IF;
    END IF;

    -- Log the transaction
    INSERT INTO account_points_history (account_id, point_type, amount, balance_after, reason, source, admin_id)
    VALUES (p_account_id, p_point_type, p_amount, v_new_balance, p_reason, p_source, p_admin_id);
END //
DELIMITER ;

-- ============================================================================
-- EXAMPLE USAGE
-- ============================================================================

-- Add 100 donation points to account ID 1:
-- CALL AddAccountPoints(1, 'donation', 100, 'Bronze Pack Purchase', 'website', NULL);

-- Add 2 vote points to account ID 1:
-- CALL AddAccountPoints(1, 'vote', 2, 'TopG Vote', 'website', NULL);

-- Remove 50 donation points (purchase):
-- CALL AddAccountPoints(1, 'donation', -50, 'Purchased VIP Token', 'ingame', NULL);

-- Admin grant points:
-- CALL AddAccountPoints(1, 'donation', 500, 'Compensation for bug', 'admin', 1);

-- Check account balance:
-- SELECT * FROM account_points WHERE account_id = 1;

-- View transaction history:
-- SELECT * FROM account_points_history WHERE account_id = 1 ORDER BY created_at DESC;

-- ============================================================================
-- INITIAL DATA FOR TESTING (optional - remove in production)
-- ============================================================================

-- INSERT INTO account_points (account_id, donation_points, vote_points) VALUES
-- (1, 500, 25),
-- (2, 100, 10);
