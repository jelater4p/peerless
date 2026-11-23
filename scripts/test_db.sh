#!/usr/bin/env bash
# Veritabanı migration'larını boş bir yerel Postgres veritabanında test eder.
# Gerekenler: PostgreSQL 15+ (psql) ve çalışan bir sunucu.
# Kullanım:  PGHOST=localhost PGPORT=5432 PGUSER=postgres scripts/test_db.sh
set -euo pipefail

cd "$(dirname "$0")/.."
DB="peerless_test"

psql -q -d postgres -c "drop database if exists $DB" -c "create database $DB"
# Rolleri her çalıştırmada temiz kur
psql -q -d postgres -c "drop role if exists anon" -c "drop role if exists authenticated" -c "drop role if exists service_role" >/dev/null 2>&1 || true

psql -q -v ON_ERROR_STOP=1 -d "$DB" -f supabase/tests/supabase_stub.sql

for f in supabase/migrations/*.sql; do
  echo "→ $f"
  # pg_net / pg_cron yerelde yok; taklitleri supabase_stub.sql'de.
  sed -E 's/^create extension if not exists (pg_net|pg_cron);//' "$f" \
    | psql -q -v ON_ERROR_STOP=1 -d "$DB"
done

psql -q -v ON_ERROR_STOP=1 -d "$DB" -o /dev/null -f supabase/tests/rls_test.sql
