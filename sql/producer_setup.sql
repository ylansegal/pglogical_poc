SELECT pglogical.create_node(
    node_name := 'provider1',
    dsn := 'host=producer port=5433 dbname=postgres'
);


SELECT pglogical.create_replication_set(
  'postgres_replication_set',
  true,
  true,
  false,
  false);

SELECT pglogical.replication_set_add_table(
  'postgres_replication_set',
  'widgets');
