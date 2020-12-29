set pg_env="C:\Program Files\PostgreSQL\11\bin"
%pg_env%\pg_dump.exe --dbname=postgresql://postgres:Csv0202@localhost:5433/calendar > BackupHistory/calendar.sql
