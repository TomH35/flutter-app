-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Hostiteľ: 127.0.0.1:3307
-- Čas generovania: So 24.Okt 2026, 11:29
-- Verzia serveru: 11.4.9-MariaDB
-- Verzia PHP: 8.3.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Databáza: `projekt_db`
--

-- --------------------------------------------------------

--
-- Štruktúra tabuľky pre tabuľku `places`
--

DROP TABLE IF EXISTS `places`;
CREATE TABLE IF NOT EXISTS `places` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `category` enum('nature','city','food','culture','other') NOT NULL DEFAULT 'other',
  `rating` tinyint(3) UNSIGNED NOT NULL DEFAULT 3,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `photo` varchar(255) DEFAULT NULL,
  `is_favorite` tinyint(1) NOT NULL DEFAULT 0,
  `visited_at` date DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_places_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Sťahujem dáta pre tabuľku `places`
--

INSERT INTO `places` (`id`, `name`, `description`, `category`, `rating`, `latitude`, `longitude`, `photo`, `is_favorite`, `visited_at`, `created_at`, `updated_at`) VALUES
(1, 'Bratislavský hrad', 'Výhľad na Dunaj a staré mesto.', 'culture', 5, 48.1421000, 17.1000000, NULL, 1, '2026-05-14', '2026-10-24 13:03:04', '2026-10-24 13:06:11'),
(2, 'Štrbské pleso', 'Prechádzka okolo plesa, krásne počasie.', 'nature', 5, 49.1193000, 20.0614000, NULL, 0, '2026-07-02', '2026-10-24 13:03:04', '2026-10-24 13:03:04'),
(3, 'Košice – Hlavná ulica', 'Spievajúca fontána a Dóm sv. Alžbety.', 'city', 4, 48.7203000, 21.2581000, NULL, 0, '2026-08-21', '2026-10-24 13:03:04', '2026-10-24 13:03:04'),
(6, 'Test lokacia', 'Test', 'culture', 5, 48.3089460, 18.0917240, 'uploads/3b7a1a713785fd02f2b775a13d842932.jpg', 0, '2026-10-22', '2026-10-24 13:16:38', '2026-10-24 13:16:38');
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
