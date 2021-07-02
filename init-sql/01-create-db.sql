CREATE DATABASE pw_user_db;
CREATE TABLE `pw_user_db`.`user_info` (`user_id` INT NOT NULL AUTO_INCREMENT, `username` VARCHAR(50), `password` VARCHAR(50), `FirstName` VARCHAR(50) NOT NULL, `LastName` VARCHAR(50), `BirthYear` INT, `Manager` TINYINT(1), PRIMARY KEY (`user_id`));
CREATE TABLE `pw_user_db`.`common_passwords` (`commonpass_id` INT AUTO_INCREMENT, `password` VARCHAR(50), PRIMARY KEY (`commonpass_id`));
