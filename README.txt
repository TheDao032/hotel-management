###How To Config And Run Server And Client

1./ create folder environments base on environments_default (on app and client) (Change file environment.dev.js base on your local postgres)
2./ build common's module (go to ./common and use commandline 'tsc' to build module [install typescript package if tsc is not defined])
3./ start server: (go to ./app and use commandline 'nodemon app' to start server) (go to ./client and use commandline 'ng serve --host 0.0.0.0' to start client)

###Database (postgresql)
    $$Window:
        $backup (create file .bat and copy below commandline into this file and run):
            commandline: set pg_env="C:\Program Files\PostgreSQL\<version>\bin"
                        %pg_env%\pg_dump.exe -h <host_ip> -p <port> -U <db_username> <db_name> > <sql_file>
                        pause
            note: create <sql_file> first before backup
        $restore (create file .bat and copy below commandline into this file and run):
            commandline:
                set pg_env="C:\Program Files\PostgreSQL\<version>\bin"
                %pg_env%\dropdb.exe -h <host_ip> -p <port> -U postgres <db_name>
                %pg_env%\createdb.exe -h <host_ip> -p <port> -U postgres <db_name>
                %pg_env%\psql.exe -h <host_ip> -p <port> -U postgres <db_name> < "<sql_file>"
                pause