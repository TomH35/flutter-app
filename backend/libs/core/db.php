<?php

require_once __DIR__ . '/../../vendor/autoload.php';

use Dotenv\Dotenv;

/**
 * Provides a single shared PDO connection to the MariaDB database.
 * Connection data is read from backend/.env.
 */
class Database
{
    private static ?PDO $connection = null;

    public static function getConnection(): PDO
    {
        if (self::$connection === null) {
            self::loadEnv();

            $dsn = sprintf(
                'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
                $_ENV['DB_HOST'],
                $_ENV['DB_PORT'],
                $_ENV['DB_NAME']
            );

            self::$connection = new PDO($dsn, $_ENV['DB_USER'], $_ENV['DB_PASSWORD'], [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ]);
        }

        return self::$connection;
    }

    private static function loadEnv(): void
    {
        $dotenv = Dotenv::createImmutable(dirname(__DIR__, 2));
        $dotenv->load();
        $dotenv->required(['DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_USER', 'DB_PASSWORD']);
    }
}
