INSERT INTO widgets(name, created_at, updated_at) VALUES(MD5(random()::text), NOW(), NOW())
