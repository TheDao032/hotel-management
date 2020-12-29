const path = require('path')
const log4js = require('log4js')

log4js.configure({
    appenders: {
        kensyuu: {
            type: 'file',
            filename: path.join(__dirname, '../log/debug1.log'),
        },
    },
    categories: {
        default: {
            appenders: ['kensyuu'],
            level: 'trace',
        },
    },
})

module.exports = {
    /** @classLog: Class name
     *  @logText: content log
     *  @typeLog: 'trace'|| 'debug'||'info'||'warn'||'error'||'fatal'
     */
    writelog(classLog, logText, typeLog) {
        const logger = log4js.getLogger(classLog)
        switch (typeLog) {
            case 'trace':
                return logger.trace(logText)
            case 'debug':
                return logger.debug(logText)
            case 'info':
                return logger.info(logText)
            case 'warn':
                return logger.warn(logText)
            case 'error':
                return logger.error(logText)
            case 'fatal':
                return logger.fatal(logText)
            default:
                return ''
        }
    },
}
