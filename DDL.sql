CREATE DATABASE IF NOT EXISTS backup;

USE backup;

CREATE TABLE IF NOT EXISTS backup_log (
    backup_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    backup_date DATETIME NOT NULL,
    backup_type VARCHAR(255) NOT NULL,
    backup_status ENUM ('OK', 'ERRO') NOT NULL,
    backup_dir VARCHAR(255) NOT NULL,
    backup_retained ENUM ('SIM', 'NAO') NOT NULL,
    backup_log VARCHAR(255) NULL,
    CONSTRAINT pk_backup_log_id PRIMARY KEY (id),
    CONSTRAINT uk_backup_log_date_type UNIQUE KEY (date, type)
);
