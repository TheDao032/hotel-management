const express = require('express')
const dateformat = require('dateformat')
const Regex = require('regex')
const moment = require('moment')
const employee = require('../middlewares/employee')

const router = express.Router()
const db = require('../models/db')

router.post('/out', async (req, res) => {
    const { id_emp, id_check_in, price } = req.body

    const toNumber = (number) => (number === '' || number === undefined || number === null || Number.isNaN(Number(number)) ? 'NULL' : number)
    const toDate = (date) => (date && !Number.isNaN(Number(Date.parse(date))) && `'${dateformat(date, 'yyyy/mm/dd')}'`) || 'NULL'
    const toText = (text) => (text && `'${text}'`) || 'NULL'

    const checkoutQuery = `
        INSERT INTO tbl_check_out (id_emp_co, id_ci_co, price_co)
        VALUES (
            ${toText(id_emp)},
            ${toNumber(id_check_in)},
            ${toNumber(price)},
        )
    `

    await db.postgre.run(checkoutQuery).catch((err) => {
        return res.status(500).json({
            err,
            code: 0,
        })
    })

    return res.status(200).json({
        code: 1,
    })
})

router.post('/statistical', async (req, res) => {
    const { from, to } = req.body
    const dateFrom = moment(from).format('YYYY-MM-DD')
    const dateTo = moment(to).format('YYYY-MM-DD')
    const statisticalQuery = `
        SELECT SUM(price_co) as price
            FROM tbl_check_out
        WHERE
        AND datecreate_co <= '${dateTo}'
        AND end_date >= '${dateFrom}'
    `

    const statisticalResult = await db.postgre.run(statisticalQuery).catch((err) => {
        return res.status(500).json({
            err,
            code: 0,
        })
    })

    if (!statisticalResult.rows) {
        return res.status(500).json({
            data: [],
            code: 0,
        })
    }
    return res.status(200).json({
        data: statisticalResult.rows,
    })
})

module.exports = router
