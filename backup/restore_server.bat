set pg_env="C:\Program Files\PostgreSQL\12\bin"
%pg_env%\psql.exe -h 192.168.11.18 -p 5432 -U postgres -f kill_local.sql
%pg_env%\dropdb.exe -h 192.168.11.18 -p 5432 -U postgres kaigi
%pg_env%\createdb.exe -h 192.168.11.18 -p 5432 -U postgres kaigi
%pg_env%\psql.exe -h 192.168.11.18 -p 5432 -U postgres kaigi < "kaigi.sql"
pause
