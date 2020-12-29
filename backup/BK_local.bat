set pg_env="C:\Program Files\PostgreSQL\11\bin"
%pg_env%\pg_dump.exe -h localhost -p 5432 -U postgres kensyuu_postgres > kensyuu_postgres.sql
pause

