@echo off

for /f "delims=" %%a in ('wmic OS Get localdatetime ^| find "."') do set DateTime=%%a

set Yr=%DateTime:~0,4%
set Mon=%DateTime:~4,2%
set Day=%DateTime:~6,2%
set Hr=%DateTime:~8,2%
set Min=%DateTime:~10,2%
set Sec=%DateTime:~12,2%

set BackupName=BackupHistory/calendar_%Yr%-%Mon%-%Day%_(%Hr%-%Min%-%Sec%)
set pg_env="C:\Program Files\PostgreSQL\11\bin"
%pg_env%\pg_dump.exe --dbname=postgresql://postgres:Csv0202@localhost:5433/calendar > %BackupName%

pause
