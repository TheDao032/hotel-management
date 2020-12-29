  @echo off
  set pg_env="C:\Program Files\PostgreSQL\12\bin"
  :: Start: Thiết lập timestamp
  for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
  set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
  set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
  :: End: Thiết lập timestamp
  set "fullstamp=%YYYY%%MM%%DD%%HH%%Min%%Sec%"
  set bkFolder="C:\Program Files\DmsWebsite\Project\dms\others\backup\bk"
  set BACKUP_FILE=dms_%fullstamp%.sql

  echo backup file name is %BACKUP_FILE%
  set PGPASSWORD=Csv0202
  echo on
  :: Start: Chọn thư mục chứa file backup
  if not exist %bkFolder% mkdir %bkFolder%
  cd %bkFolder%
  :: End: Chọn thư mục chứa file backup
  %pg_env%\pg_dump.exe --dbname=postgresql://postgres:%PGPASSWORD%@localhost:5432/dms > %BACKUP_FILE%