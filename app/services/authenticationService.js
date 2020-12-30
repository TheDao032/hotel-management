/* eslint-disable prettier/prettier */
const ldap = require('ldapjs')
const moment = require('moment')
const environments = require('../environments/environment')
const db = require('../models/db')
const queryService = require('./queryService')

const getPermission = (employee_cd) => {
    const today = moment().format('YYYY-MM-DD')

    const permission_cd_query = `
    SELECT *
    FROM tbl_employee_permission
    WHERE employee_id = '${employee_cd}'
      AND begin_date <= '${today}'
      AND expired_date >= '${today}'
    ORDER BY start_date DESC
  `
    //   console.log(permission_cd_query)
    return db.postgre.run(permission_cd_query).then((result) => (result.rows.length === 0 ? '01' : result.rows[0].permission_cd))
}

const authenticate = (username, password, callback) => {

    const email = username + environments.subMail
    const shain_cd_query = `
            SELECT *
            FROM m_shain WHERE mail_address = '${email}'
        `
    return db.oracle
        .run(shain_cd_query)
        .then((result) => {
            if (result.rows.length === 0) {
                throw new Error('User not found')
            }

            const [info] = result.rows
            const fullname = `${info.shain_sei} ${info.shain_nm}`
            const { shain_cd } = info
            const auth = {
                username,
                shain_cd,
            }

            return Promise.all([
                auth,
                getPermission(shain_cd).then((permission_cd) => {
                    return {
                        permission_cd,
                        fullname,
                        shain_cd,
                    }
                }),
            ])
        })
        .then(([auth, info]) => {
            callback(null, auth, info)
        })
}

const getShainName = (employee_cd) => {
    const query = `SELECT * FROM tbl_employee_permission WHERE employee_id = '${employee_cd}'`
    return db.oracle
        .run(query)
        .then((result) => {
            if (result.rows.length === 0) return ''
            return `${result.rows[0].employee_name || ''} ${result.rows[0].mail_address || ''}`
        })
        .catch(() => {
            return ''
        })
}

const getShainInfo = (shain_cd) => {
    const query = `
        SELECT *
        FROM (${queryService.employeeInfo()}) SHAIN_LIST
        WHERE SHAIN_CD = '${shain_cd}'
    `
    return db.postgre.run(query).then((res) => res.rows[0])
}

module.exports = {
    getShainName,
    getPermission,
    authenticate,
    getShainInfo,
}
