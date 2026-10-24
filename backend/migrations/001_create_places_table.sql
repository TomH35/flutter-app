-- Places visited by the user (Flutter model: lib/models/place.dart)

CREATE TABLE IF NOT EXISTS places (
    id           INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    name         VARCHAR(100)     NOT NULL,
    description  TEXT             NULL,
    category     ENUM('nature', 'city', 'food', 'culture', 'other') NOT NULL DEFAULT 'other',
    rating       TINYINT UNSIGNED NOT NULL DEFAULT 3,
    latitude     DECIMAL(10, 7)   NULL,
    longitude    DECIMAL(10, 7)   NULL,
    photo        VARCHAR(255)     NULL,
    is_favorite  TINYINT(1)       NOT NULL DEFAULT 0,
    visited_at   DATE             NULL,
    created_at   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_places_category (category)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
