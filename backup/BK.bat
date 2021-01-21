set pg_env="C:\Program Files\PostgreSQL\13\bin"
%pg_env%\pg_dump.exe -h 192.168.11.145 -p 5432 -U postgres kensyuu_postgres > kensyuu_postgres.sql
pause

