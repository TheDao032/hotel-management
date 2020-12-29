const env = {
    production: false,
    ipServer: '192.168.11.166',
    PORT_METABASE: 3000,
    SECRET_KEY_METABASE: '55f2cba4bc22c57fc43818cd4c225047e609e70d31a53de3ab34ac449c1088c5',
    PORT: 3302, // port server
    configDatabase: {
        user: 'postgres',
        password: 'Csv0202',
        port: 5433,
        database: 'kensyuuLocal',
        host: '192.168.11.166',
        max: 10, // max number of connection can be open to database
        idleTimeoutMillis: 5000, // how long a client is allowed to remain idle before being closed
    },
    configOCDatabaseAD: {
        user: 'c##kensyuu_oracle',
        password: 'Csv0202',
        port: 1521,
        connectionString: '192.168.11.135/XE',
    },
    configAD: {
        serverIp: '192.168.11.20',
        domain: 'cubevn.local',
    },
    subMailTag: ['@gmail.com', '@vn-cubesystem.com'],
    secret: 'kensyuu_csv0202',
    subMail: '@vn-cubesystem.com',
    teacherMail: 'lapthien@vn-cubesystem.com',
    mailConfig: {
        host: 'smtp3.gmoserver.jp',
        port: 587,
        secure: false,
        auth: {
            user: 'kenshuukanri@vn-cubesystem.com',
            pass: 'Csv#0202',
        },
    },
    APP_ID: 'c8552068-1cfc-47bd-a734-706ecb53e792',
    APP_PASSWORD: 'oq:f16Lg:W1z:a0EgCNrRcdUcdpXHk-q',
    APP_SCOPES: 'openid profile offline_access User.Read Mail.Read Calendars.ReadWrite',
    REDIRECT_URI: `http://localhost:4200/training/list`,
}

module.exports = env
