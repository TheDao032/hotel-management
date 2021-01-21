const express = require('express')
const dateformat = require('dateformat')
const employee = require('../middlewares/employee')

const router = express.Router()
const db = require('../models/db')

router.post('/cre', async (req, res) => {
    const { username, permission, begin, expired } = req.body
    let id_acc = await employee.random()
    while (id_acc === '') {
        id_acc += await employee.random()
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
