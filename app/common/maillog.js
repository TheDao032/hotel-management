const db = require('../models/db')
/**
 *
 * @param {const} mail_from
 * @param {const} mail_to
 * @param {const} mail_html
 * @param {const} mail_query
 * @param {const} mail_result
 * Được sử dụng ở mailService
 * Lấy dữ liệu mail_from, mail_to, mail_html, mail_query, mail_result được truyền từ  mailService
 * Dữ liệu được mã hóa và insert vào bảng tbl_mail_log của postgre
 */
const updateLogMail = (mail_from, mail_to, mail_html, mail_query, mail_result) => {
    const mail_query1 = escape(mail_query)
    const mail_html1 = escape(mail_html)
    const mail_result1 = escape(mail_result)
    // unescape(mail_html1)
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
