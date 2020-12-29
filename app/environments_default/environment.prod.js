const env = {
    production: true,
    ipServer: '192.168.150.40',
    PORT_METABASE: 3000,
    SECRET_KEY_METABASE: '2968673d1d1a2967cc756fb8f177d1da7931319a4da21051e3b6ebf3f6aa635c',
    PORT: 3301, // port server
    configDatabase: {
        user: 'postgres',
        password: 'KensyuuK@nri',
        port: 5432,
        database: 'kensyuukanri',
        host: 'localhost',
        max: 10, // max number of connection can be open to database
        idleTimeoutMillis: 5000, // how long a client is allowed to remain idle before being closed
    },
    configOCDatabaseAD: {
        user: 'cost_viewer',
        password: 'cost_viewer1',
        port: 1521,
        host: '192.168.146.39',
        connectionString: '192.168.146.39' + '/erpd',
    },
    configAD: {
        serverIp: '192.168.145.26',
        domain: 'cube.cubesystem.co.jp',
    },
    secret: 'cubesystemvn',
    subMail: '@cubesystem.co.jp', // @vn-cubesystem.com
    teacherMail: 'kyouiku@cubesystem.co.jp',
    mailConfig: {
        host: 'smtp3.gmoserver.jp',
        port: 587,
        secure: false,
        auth: {
            user: 'kenshuukanri@vn-cubesystem.com',
            pass: 'Csv#0202',
        },
    },
}

module.exports = env
