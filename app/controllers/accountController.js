const express = require('express')
const dateFormat = require('dateformat')

const router = express.Router()
const db = require('../models/db')

router.post('/create', async (req, res) => {
    const { username, permission , begin, expired } = req.body
    const password = 'htm2021'
    const status = 0
    const beginDate = new Date(begin)
    const expiredDate = new Date(expired)
    const createQuery = `
        INSERT INTO tbl_account (username_acc, pass_acc, id_per_acc, status_acc, datebegin_acc, dateexpired_acc)
        VALUES (
            '${username}',
            '${password}',
            '${permission}',
            ${status}, ${beginDate}, ${expiredDate}
        )
    `
    return await db.postgre.run(createQuery).catch((err) => {
        return res.status(500).json({
            err,
        })
    })
})

module.exports = router
