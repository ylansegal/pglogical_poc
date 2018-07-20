CREATE EXTENSION IF NOT EXISTS pglogical;

-- On all nodesz
-- CREATE EXTENSION pglogical_origin; -- Only needed for PostgreSQL 9.4
SELECT
    pglogical.create_node (node_name := 'provider1',
        dsn := 'host=producer port=5433 dbname=postgres password=mysecretpassword');

SELECT
    pglogical.create_replication_set (set_name := 'postgres_replication_set',
        replicate_insert := TRUE,
        replicate_update := TRUE,
        replicate_delete := FALSE,
        replicate_truncate := FALSE);

SELECT
    pglogical.replication_set_add_table (set_name := 'postgres_replication_set',
        relation := 'widgets',
        synchronize_data := TRUE);
