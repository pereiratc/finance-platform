-- Run all three scripts in sequence
:r /docker-entrypoint-initdb/01-schema.sql
:r /docker-entrypoint-initdb/02-seed-reference-data.sql
:r /docker-entrypoint-initdb/03-seed-transactions.sql