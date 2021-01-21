const ldap = require('ldapjs')
const moment = require('moment')
const environments = require('../environments/environment')
const db = require('../models/db')
const queryService = require('./queryService')

const getPermission = (employee_cd) => {
    const today = moment().format('YYYY-MM-DD')

    const permission_cd_query = `
    SELECT *
    FROM tbl_account
    WHERE id_emp_acc = '${employee_cd}'
      AND datebegin_acc <= '${today}'
      AND dateexpired_acc >= '${today}'
    ORDER BY datebegin_acc DESC
  `
    return db.postgre.run(permission_cd_query).then((result) => (result.rows.length === 0 ? '0' : result.rows[0].id_per_acc))
}

const authenticate = (username, password, callback) => {

    const employee_query = `
            SELECT *
            FROM tbl_account WHERE username_acc = '${username}' AND pass_acc = '${password}'
        `
    return db.postgre
        .run(employee_query)
        .then((result) => {
            if (result.rows.length === 0) {
                throw new Error('User not found') }

            const [info] = result.rows
            const username = `${info.username_acc}`
            const { id_emp_acc } = info
            const auth = {
                username,
                id_emp_acc,
            }

            return Promise.all([
                auth,
                getPermission(id_emp_acc).then((permission) => {
                    return {
                        permission,
                        username,
                        id_emp_acc,
                    }
                }),
            ])
        })
        .then(([auth, info]) => {
            callback(null, auth, info)
        })
}

const getEmployeeName = (employee_id) => {
    const query = `SELECT * FROM tbl_employee WHERE id_emp_acc = '${employee_id}'`
    return db.postgre
        .run(query)
        .then((result) => {
            if (result.rows.length === 0) return ''
            return `${result.rows[0].name_emp || ''}`
        })
        .catch(() => {
            return ''
        })
}

const getEmployeeInfo = (employee_id) => {
    const query = `
        SELECT *
        FROM (${queryService.employeeInfo()}) employee_list
        WHERE id_emp = '${employee_id}'
    `
    return db.postgre.run(query).then((res) => res.rows[0])
}

module.exports = {
    getEmployeeName,
    getPermission,
    authenticate,
    getEmployeeInfo,
}
