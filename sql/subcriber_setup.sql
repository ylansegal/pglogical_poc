CREATE EXTENSION IF NOT EXISTS  pglogical;

SELECT pglogical.create_node(
    node_name := 'subscriber1',
    dsn := 'host=subscriber port=5432 dbname=postgres password=mysecretpassword'
);


SELECT pglogical.create_subscription(
  'widget_subscription',
  'host=producer port=5432 dbname=postgres password=mysecretpassword',
  '{postgres_replication_set}',
  true,
  true);
