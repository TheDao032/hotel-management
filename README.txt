###How To Config And Run Server And Client

1./ create folder environments base on environments_default (on app and client) (Change file environment.dev.js base on your local postgres)
2./ build common's module (go to ./common and use commandline 'tsc' to build module [install typescript package if tsc is not defined])
3./ start server: (go to ./app and use commandline 'nodemon app' to start server) (go to ./client and use commandline 'ng serve --host 0.0.0.0' to start client)
