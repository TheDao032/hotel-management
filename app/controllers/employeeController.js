const express = require('express')
const dateformat = require('dateformat')
const employee = require('../middlewares/employee')
const Regex = require('regex')

const router = express.Router()
const db = require('../models/db')

router.post('/search', async (req, res) => {
    const { param } = req.body
    const toNumber = (number) => (number === '' || number === undefined || number === null || Number.isNaN(Number(number)) ? 'NULL' : number)
    const toText = (text) => (text && `'${text}'`) || 'NULL'
    const toDate = (date) => (date && !Number.isNaN(Number(Date.parse(date))) && `'${dateformat(date, 'yyyy/mm/dd')}'`) || 'NULL'
    const toBit = (bit) => `'${(bit && 1) || 0}'`
    const toArray = (array) => `${array ? `'{${array}}'` : 'NULL'}`
    const getQuery = param !== ''
        ? `
            SELECT *
                FROM tbl_employee
            WHERE
                id_emp = ${toNumber(param.trim())} OR name_emp LIKE ${toText(param.trim())} OR cardid_emp LIKE ${toText(param.trim())}
                OR mail_emp LIKE ${toText(param.trim())} OR address_emp like ${toText(param.trim())} OR status_emp = ${toNumber(param.trim())}
        `
        : `
            SELECT *
                FROM tbl_employee
        `
    const getResult = await db.postgre.run(getQuery).catch((err) => {
        return res.status(500).json({
            err,
            code: 0,
        })
    })

    if (getResult.rows.length === 0) {
        return res.status(200).json({
            data: [],
            code: 0,
        })
    }
    return res.status(200).json({
        data: getResult.rows,
        code: 1,
    })
})

router.post('/id', async (req, res) => {
    const { id_emp } = req.body
    const getQuery = `
        SELECT *
            FROM tbl_employee
        WHERE id_emp = '${id_emp}'
    `
    const getResult = await db.postgre.run(getQuery).catch((err) => {
        return res.status(500).json({
            err,
            code: 0,
        })
    })

    if (getResult.rows.length === 0) {
        return res.status(200).json({
            data: [],
            code: 0,
        })
    }
    return res.status(200).json({
        data: getResult.rows[0],
        code: 1,
    })
})

router.post('/cre', async (req, res) => {
    const { username, permission, begin, expired } = req.body
    var id_acc = await employee.random()
    while (id_acc === '') {
        id_acc = await employee.random()
    }
    const pass = `htm2021`
    const status = 0
    const toDate = (date) => (date && !Number.isNaN(Number(Date.parse(date))) && `'${dateformat(date, 'yyyy/mm/dd')}'`) || 'NULL'
    const dateBegin = toDate(begin)
    const dateExpired = toDate(expired)
    const queryInsert = `
        INSERT INTO tbl_account (id_acc, username_acc, pass_acc, id_per_acc, status_acc, datebegin_acc, dateexpired_acc)
        VALUES (
            '${id_acc}',
            '${username}',
            '${pass}',
            ${permission},
            ${status},
            ${dateBegin},
            ${dateExpired}
        );
    `
    await db.postgre.run(queryInsert).catch((err) => {
        return res.status(500).json({
            err,
        })
    })
    return res.status(200).json({
        code: 1,
    })
})

module.exports = router
