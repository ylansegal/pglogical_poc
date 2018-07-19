CREATE EXTENSION IF NOT EXISTS  pglogical;

SELECT pglogical.create_node(
    node_name := 'subscriber1',
    dsn := 'host=subscriber port=5432 dbname=postgres'
);


SELECT pglogical.create_subscription(
  'widget_subscription',
  'host=producer port=5432 dbname=postgres password=mysecretpassword',
  '{postgres_replication_set}',
  true,
  true);

-- ERROR:  could not connect to the postgresql server in replication mode: FATAL:  no pg_hba.conf entry for replication connection from host "172.18.0.3", user "postgres", SSL off
