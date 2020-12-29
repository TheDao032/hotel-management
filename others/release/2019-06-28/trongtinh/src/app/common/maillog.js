const db = require('../models/db')

const updateLogMail = (mail_from, mail_to, mail_html, mail_query, mail_result) => {
    const mail_query1 = escape(mail_query)
    const mail_html1 = escape(mail_html)
    const mail_result1 = escape(mail_result)
        //unescape(mail_html1)
    const sql = `
        INSERT INTO public.tbl_mail_log
            (mail_from, mail_to, mail_html, mail_query, mail_result )
        VALUES ('${mail_from}',' ${mail_to}', '${mail_html1}', '${mail_query1}','${mail_result1}')
        RETURNING id;
    `
    db.postgre
        .run(sql)
        .then((result) => {
            if (result.rows.length !== 0) {
                return {
                    code: 0,
                }
            }

            if (result.rows.length === 0) {
                return {
                    code: 1,
                }
            }
        })
        .catch((error) => {
            return {
                code: 2,
            }
        })
}

module.exports = { updateLogMail }
