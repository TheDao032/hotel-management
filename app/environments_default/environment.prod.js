const env = {
    production: false,
    ipServer: '192.168.11.145',
    PORT_METABASE: 3000,
    SECRET_KEY_METABASE: '55f2cba4bc22c57fc43818cd4c225047e609e70d31a53de3ab34ac449c1088c5',
    PORT: 3302, // port server
    configDatabase: {
        user: 'postgres',
        password: 'Csv0202',
        port: 5432,
        database: 'hotel-management',
        host: '192.168.11.145',
        max: 10, // max number of connection can be open to database
        idleTimeoutMillis: 5000, // how long a client is allowed to remain idle before being closed
    },
    
    secret: 'hotel-manage',
    subMail: '@gmail.com',
    mailConfig: {
        host: 'smtp3.gmoserver.jp',
        port: 587,
        secure: false,
        auth: {
            user: '',
            pass: '',
        },
    },
}

module.exports = env
