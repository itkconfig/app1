-- Create users for container access
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'dev_root_123';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

CREATE USER IF NOT EXISTS 'root'@'localhost' IDENTIFIED BY 'dev_root_123';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;

-- Create dedicated PHPMyAdmin user
CREATE USER IF NOT EXISTS 'phpmyadmin'@'%' IDENTIFIED BY 'dev_root_123';
GRANT ALL PRIVILEGES ON *.* TO 'phpmyadmin'@'%' WITH GRANT OPTION;

-- Create WordPress database if not exists
CREATE DATABASE IF NOT EXISTS wordpress;

FLUSH PRIVILEGES;
