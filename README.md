https://www.2ndquadrant.com/en/resources/pglogical/pglogical-docs/

To start:

$ docker-compose up

shortcuts.sh contains helpful shortcuts for conecting to database

In producer database:
  - \i sql/schema.lsq
  - \i sql/insert_data.sql
  - Run the steps in sql/producer_setup.sql

In subscriber database:
  - Run the steps in sql/subscriber_setup.sql

The replication is not complete;
