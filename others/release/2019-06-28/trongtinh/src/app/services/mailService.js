const nodemailer = require('nodemailer')
const mail = require('../common/mail')
const defaultEnvironment = require('../environments/environment.dev')
const logmail = require('../common/maillog')
module.exports = {
    /**
     * Sends email via smtp
     * @param {Object} mailOptions Needs params: From, To, Subject, text.
     * @param {*} mailConfig
     */
    async send(mailOptions, totalQuery = '', resultQuery = '') {
        // if (!defaultEnvironment.subMailTag.includes(mailOptions)) {
        //     return
        // }
        console.log(resultQuery)
        const checkMail = defaultEnvironment.subMailTag.map((e) => {
            if (mailOptions.to.includes(e) === true) {
                return 1
            }
        })
        if (checkMail.includes(1) === false) {
            return
        }
        let dataMailConfig = {}
        const mailConfig = await mail.getMailConfig()
        if (mailConfig.code === 0) {
            dataMailConfig = mailConfig.data
            const usableMailConfig = {
                host: dataMailConfig.host,
                port: dataMailConfig.port,
                secure: dataMailConfig.secure,
                auth: {
                    user: dataMailConfig.usermail_auth,
                    pass: dataMailConfig.passmail_auth,
                },
            }
            usableMailConfig.from = mailOptions.from || usableMailConfig.usermail_auth

            // mailOptions.to = mailOptions.to || "kyouiku@cubesystem.co.jp"
            usableMailConfig.to = mailOptions.to // sau nay se xoa di

            usableMailConfig.text = mailOptions.text || null
            usableMailConfig.html = mailOptions.html || null
            usableMailConfig.subject = mailOptions.subject
            usableMailConfig.cc = mailOptions.cc
            logmail.updateLogMail(usableMailConfig.from, usableMailConfig.to, usableMailConfig.html, totalQuery, resultQuery)
            return
            const transporter = nodemailer.createTransport(usableMailConfig)
            return transporter.sendMail(usableMailConfig).then(
                (success) => {},
                (error) => {
                    throw new Error({
                        code: 4,
                    })
                }
            )
        }
        if (mailConfig.code === 1) {
            return new Error({ code: 2 })
        }
        throw new Error({ code: 3 })
    },
}
