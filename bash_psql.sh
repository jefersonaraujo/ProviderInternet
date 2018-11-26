#!/bin/bash

set -e
set -u

# Fazer consultas psql setando senha.
export PGHOST=${PGHOST-localhost}
export PGPORT=${PGPORT-5432}
export PGDATABASE=${PGDATABASE-my_database}
export PGUSER=${PGUSER-my_user}
export PGPASSWORD=${PGPASSWORD-my_password}

RUN_PSQL="psql -X --set AUTOCOMMIT=off --set ON_ERROR_STOP=on "

${RUN_PSQL} <<SQL
select blah_column 
  from blahs 
 where blah_column = 'foo';
rollback;
SQL
