INSERT INTO widgets (name, created_at, updated_at)
SELECT
    MD5(random()::text), NOW(), NOW()
FROM
    generate_series(1, 100) s (i);
