/* eslint-disable prettier/prettier */
/* eslint-disable no-console */
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
        /*
            Phần kiểm tra mail có submail ở enviroment_DEV
            Lưu ý tắt câu lệnh if này đi khi đưa lên server Nhật
        */
        if (!defaultEnvironment.subMailTag.find((e) => mailOptions.to.includes(e))) {
            return
        }
        // Close at 2019/11/07
        // if (!defaultEnvironment.subMailTag.find((e) => mailOptions.to.includes(e))) {
        //     return
        // }

        // const checkMail = defaultEnvironment.subMailTag.map((e) => {
        //     if (mailOptions.to.includes(e) === true) {
        //         return 1
        //     }
        // })
        // if (checkMail.includes(1) === false) {
        //     return
        // }
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
            /** Outlook event Invitation được gắn vào attachments của nodemailer */
            /** Google event Invitation được gắn vào icalEvent của nodemailer: https://nodemailer.com/message/calendar-events/ */
            // usableMailConfig.attachments = mailOptions.attachments || []
            // usableMailConfig.icalEvent = mailOptions.icalEvent || {}
            logmail.updateLogMail(usableMailConfig.from, usableMailConfig.to, usableMailConfig.html, totalQuery, resultQuery)
            const transporter = nodemailer.createTransport(usableMailConfig)
            transporter.sendMail(usableMailConfig).then(
                (success) => {console.log(success)},
                (error) => {
                    console.log(error)
                    throw new Error({
                        code: 4,
                    })
                }
            )
            return
        }
        if (mailConfig.code === 1) {
            throw new Error({ code: 2 })
        }

        throw new Error({ code: 3 })
    },
}
