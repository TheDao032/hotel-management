set pg_env="C:\Program Files\PostgreSQL\11\bin"
%pg_env%\pg_dump.exe --dbname=postgresql://postgres:2705@localhost:5432/hotel_management > BackupHistory/db.sql
