#!/usr/bin/env bash

echo "Allowing replication from subscriber..."
echo "host replication postgres samenet trust" >> /var/lib/postgresql/data/pg_hba.conf
