const db = require('../models/db')
/*
 *- Kiểm tra ở có hàng ở bảng tbl_mail_config hay không?
 *- Nếu có trả về code: 0 và không có thì trả về code: 1.
 */
const getMailConfig = () => {
    return new Promise((resolve, reject) => {
        const sql = `SELECT * FROM tbl_mail_config`
        db.postgre
            .run(sql)
            .then((result) => {
                if (result.rows.length !== 0) {
                    resolve({
                        code: 0,
                        data: result.rows[0],
                    })

                    return
                }

                if (result.rows.length === 0) {
                    resolve({
                        code: 1,
                        data: [],
                    })
                }
            })
            .catch((error) => {
                return reject(error)
            })
    })
}

module.exports = { getMailConfig }
