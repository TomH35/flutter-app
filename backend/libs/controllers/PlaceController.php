<?php

require_once __DIR__ . '/../core/db.php';
require_once __DIR__ . '/../core/ApiException.php';

class PlaceController
{
    private const CATEGORIES = ['nature', 'city', 'food', 'culture', 'other'];

    private const UPLOAD_DIR = __DIR__ . '/../../uploads/';
    private const MAX_PHOTO_SIZE = 5 * 1024 * 1024;
    private const PHOTO_TYPES = [
        IMAGETYPE_JPEG => 'jpg',
        IMAGETYPE_PNG => 'png',
        IMAGETYPE_WEBP => 'webp',
        IMAGETYPE_GIF => 'gif',
    ];

    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    public function getAll(): array
    {
        $rows = $this->db
            ->query('SELECT * FROM places ORDER BY created_at DESC, id DESC')
            ->fetchAll();

        return array_map([$this, 'mapRow'], $rows);
    }

    public function getById(int $id): array
    {
        return $this->mapRow($this->findRow($id));
    }

    public function create(array $data): array
    {
        $place = $this->validate($data);

        $stmt = $this->db->prepare(
            'INSERT INTO places (name, description, category, rating, latitude, longitude, photo, is_favorite, visited_at)
             VALUES (:name, :description, :category, :rating, :latitude, :longitude, :photo, :is_favorite, :visited_at)'
        );
        $stmt->execute($place);

        return $this->getById((int) $this->db->lastInsertId());
    }

    public function update(int $id, array $data): array
    {
        $current = $this->findRow($id);
        $place = $this->validate($data);

        $stmt = $this->db->prepare(
            'UPDATE places
             SET name = :name, description = :description, category = :category, rating = :rating,
                 latitude = :latitude, longitude = :longitude, photo = :photo,
                 is_favorite = :is_favorite, visited_at = :visited_at
             WHERE id = :id'
        );
        $stmt->execute($place + ['id' => $id]);

        if ($current['photo'] !== $place['photo']) {
            $this->deletePhotoFile($current['photo']);
        }

        return $this->getById($id);
    }

    public function delete(int $id): void
    {
        $current = $this->findRow($id);

        $stmt = $this->db->prepare('DELETE FROM places WHERE id = :id');
        $stmt->execute(['id' => $id]);

        $this->deletePhotoFile($current['photo']);
    }

    public function toggleFavorite(int $id): array
    {
        $this->findRow($id);

        $stmt = $this->db->prepare('UPDATE places SET is_favorite = NOT is_favorite WHERE id = :id');
        $stmt->execute(['id' => $id]);

        return $this->getById($id);
    }

    /**
     * Stores an uploaded image and returns its path relative to the backend folder,
     * which is then saved in the "photo" field of a place.
     */
    public function uploadPhoto(?array $file): string
    {
        if ($file === null || !isset($file['error']) || is_array($file['error'])) {
            throw new ApiException('No photo was uploaded');
        }
        if ($file['error'] === UPLOAD_ERR_INI_SIZE || $file['error'] === UPLOAD_ERR_FORM_SIZE) {
            throw new ApiException('Photo is too large', 413);
        }
        if ($file['error'] !== UPLOAD_ERR_OK) {
            throw new ApiException('Photo upload failed');
        }
        if ($file['size'] > self::MAX_PHOTO_SIZE) {
            throw new ApiException('Photo is too large (max 5 MB)', 413);
        }

        $info = @getimagesize($file['tmp_name']);
        if ($info === false || !isset(self::PHOTO_TYPES[$info[2]])) {
            throw new ApiException('Photo must be a JPG, PNG, WEBP or GIF image');
        }

        if (!is_dir(self::UPLOAD_DIR)) {
            mkdir(self::UPLOAD_DIR, 0755, true);
        }

        $filename = bin2hex(random_bytes(16)) . '.' . self::PHOTO_TYPES[$info[2]];
        if (!move_uploaded_file($file['tmp_name'], self::UPLOAD_DIR . $filename)) {
            throw new RuntimeException('Could not move uploaded file');
        }

        return 'uploads/' . $filename;
    }

    private function findRow(int $id): array
    {
        $stmt = $this->db->prepare('SELECT * FROM places WHERE id = :id');
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();

        if ($row === false) {
            throw new ApiException('Place not found', 404);
        }

        return $row;
    }

    /**
     * Validates input and returns values ready to be bound to the INSERT/UPDATE query.
     */
    private function validate(array $data): array
    {
        $name = trim((string) ($data['name'] ?? ''));
        if ($name === '') {
            throw new ApiException('Name is required', 422);
        }
        if (mb_strlen($name) > 100) {
            throw new ApiException('Name can have at most 100 characters', 422);
        }

        $description = trim((string) ($data['description'] ?? ''));
        if (mb_strlen($description) > 2000) {
            throw new ApiException('Description can have at most 2000 characters', 422);
        }

        $category = $data['category'] ?? 'other';
        if (!in_array($category, self::CATEGORIES, true)) {
            throw new ApiException('Invalid category', 422);
        }

        $rating = filter_var($data['rating'] ?? null, FILTER_VALIDATE_INT, [
            'options' => ['min_range' => 1, 'max_range' => 5],
        ]);
        if ($rating === false) {
            throw new ApiException('Rating must be a number from 1 to 5', 422);
        }

        $latitude = $this->validateCoordinate($data['latitude'] ?? null, 90, 'Latitude');
        $longitude = $this->validateCoordinate($data['longitude'] ?? null, 180, 'Longitude');
        if (($latitude === null) !== ($longitude === null)) {
            throw new ApiException('Latitude and longitude must be set together', 422);
        }

        $photo = $data['photo'] ?? null;
        if ($photo !== null && !$this->isValidPhotoPath($photo)) {
            throw new ApiException('Invalid photo', 422);
        }

        $visitedAt = $data['visited_at'] ?? null;
        if ($visitedAt !== null) {
            $date = DateTime::createFromFormat('!Y-m-d', (string) $visitedAt);
            if ($date === false || $date->format('Y-m-d') !== $visitedAt) {
                throw new ApiException('Visit date must be in YYYY-MM-DD format', 422);
            }
        }

        return [
            'name' => $name,
            'description' => $description === '' ? null : $description,
            'category' => $category,
            'rating' => $rating,
            'latitude' => $latitude,
            'longitude' => $longitude,
            'photo' => $photo,
            'is_favorite' => !empty($data['is_favorite']) ? 1 : 0,
            'visited_at' => $visitedAt,
        ];
    }

    private function validateCoordinate(mixed $value, int $limit, string $label): ?float
    {
        if ($value === null || $value === '') {
            return null;
        }
        if (!is_numeric($value) || abs((float) $value) > $limit) {
            throw new ApiException("$label must be a number between -$limit and $limit", 422);
        }

        return (float) $value;
    }

    private function isValidPhotoPath(mixed $photo): bool
    {
        return is_string($photo)
            && preg_match('#^uploads/[a-f0-9]{32}\.(jpg|png|webp|gif)$#', $photo) === 1
            && is_file(self::UPLOAD_DIR . basename($photo));
    }

    private function deletePhotoFile(?string $photo): void
    {
        if ($photo !== null && $this->isValidPhotoPath($photo)) {
            @unlink(self::UPLOAD_DIR . basename($photo));
        }
    }

    private function mapRow(array $row): array
    {
        return [
            'id' => (int) $row['id'],
            'name' => $row['name'],
            'description' => $row['description'] ?? '',
            'category' => $row['category'],
            'rating' => (int) $row['rating'],
            'latitude' => $row['latitude'] !== null ? (float) $row['latitude'] : null,
            'longitude' => $row['longitude'] !== null ? (float) $row['longitude'] : null,
            'photo' => $row['photo'],
            'is_favorite' => (bool) $row['is_favorite'],
            'visited_at' => $row['visited_at'],
            'created_at' => $row['created_at'],
        ];
    }
}
