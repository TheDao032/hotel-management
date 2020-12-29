set pg_env="C:\Program Files\PostgreSQL\12\bin"
%pg_env%\pg_dump.exe -h 192.168.11.166 -p 5433 -U postgres --inserts conference_room > kaigihonsha_insert_type.sql
pause

