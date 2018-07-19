#!/usr/bin/env bash
# runs a console against producer and subscriber databases
alias producer="PGPASSWORD=mysecretpassword psql --port=5433 --host=localhost --user=postgres"
alias subscriber="PGPASSWORD=mysecretpassword psql --port=5434 --host=localhost --user=postgres"
