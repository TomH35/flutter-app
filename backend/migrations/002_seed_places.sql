-- Optional sample data so the app is not empty on first launch

INSERT INTO places (name, description, category, rating, latitude, longitude, is_favorite, visited_at) VALUES
    ('Bratislavský hrad', 'Výhľad na Dunaj a staré mesto.', 'culture', 5, 48.1421000, 17.1000000, 1, '2026-05-14'),
    ('Štrbské pleso', 'Prechádzka okolo plesa, krásne počasie.', 'nature', 5, 49.1193000, 20.0614000, 0, '2026-07-02'),
    ('Košice – Hlavná ulica', 'Spievajúca fontána a Dóm sv. Alžbety.', 'city', 4, 48.7203000, 21.2581000, 0, '2026-08-21'),
    ('Bryndzové halušky v Ždiari', 'Najlepšie halušky, aké som jedol.', 'food', 4, 49.2706000, 20.2626000, 1, '2026-07-03');
