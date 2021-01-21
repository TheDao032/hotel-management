set pg_env="C:\Program Files\PostgreSQL\13\bin"
%pg_env%\psql.exe -h localhost -p 5432 -U postgres -f kill_local.sql
%pg_env%\dropdb.exe -h localhost -p 5432 -U postgres hotel_management
%pg_env%\createdb.exe -h localhost -p 5432 -U postgres hotel_management
%pg_env%\psql.exe -h localhost -p 5432 -U postgres hotel_management < "db.sql"
pause