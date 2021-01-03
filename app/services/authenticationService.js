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
    ORDER BY begin_date DESC
  `
    //   console.log(permission_cd_query)
    return db.postgre.run(permission_cd_query).then((result) => (result.rows.length === 0 ? '01' : result.rows[0].permission))
}

const authenticate = (username, password, callback) => {

    const email = username + environments.subMail
    const employe_query = `
            SELECT *
            FROM tbl_employee_permission WHERE mail_address = '${email}' AND password = '${password}'
        `
    return db.postgre
        .run(employe_query)
        .then((result) => {
            if (result.rows.length === 0) {
                throw new Error('User not found')
            }

            const [info] = result.rows
            const fullname = `${info.employee_name}`
            const { employee_id } = info
            const auth = {
                username,
                employee_id,
            }

            return Promise.all([
                auth,
                getPermission(employee_id).then((permission) => {
                    return {
                        permission,
                        fullname,
                        employee_id,
                    }
                }),
            ])
        })
        .then(([auth, info]) => {
            callback(null, auth, info)
        })
}

const getEmployeeName = (employee_id) => {
    const query = `SELECT * FROM tbl_employee_permission WHERE employee_id = '${employee_id}'`
    return db.postgre
        .run(query)
        .then((result) => {
            if (result.rows.length === 0) return ''
            return `${result.rows[0].employee_name || ''} ${result.rows[0].mail_address || ''}`
        })
        .catch(() => {
            return ''
        })
}

const getEmployeeInfo = (employee_id) => {
    const query = `
        SELECT *
        FROM (${queryService.employeeInfo()}) SHAIN_LIST
        WHERE employee_id = '${employee_id}'
    `
    return db.postgre.run(query).then((res) => res.rows[0])
}

module.exports = {
    getEmployeeName,
    getPermission,
    authenticate,
    getEmployeeInfo,
}
