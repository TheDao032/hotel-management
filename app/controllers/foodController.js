const express = require('express')
const dateformat = require('dateformat')
const employee = require('../middlewares/employee')
const Regex = require('regex')

const router = express.Router()
const db = require('../models/db')

router.post('/use-food', async (req, res) => {
    const { id_cus } = req.body

    const usedFood = `
        SELECT *
            FROM tbl_use_food
            LEFT JOIN tbl_customer ON id_cus = id_cus_uf
        WHERE id_cus = '${id_cus}'
    `
    const result = await db.postgre.run(usedFood).catch((err) => {
        return res.status(500).json({
            err,
            code: 0,
        })
    })

    if (result.rows) {
        return res.status(200).json({
            data: result.rows,
            code: 1,
        })
    }
    return res.status(200).json({
        code: 0,
    })

})

router.post('/insert', async (req, res) => {
    const { id_cus, id_food, number, date } = req.body

    const toNumber = (number) => (number === '' || number === undefined || number === null || Number.isNaN(Number(number)) ? 'NULL' : number)
    const toDate = (date) => (date && !Number.isNaN(Number(Date.parse(date))) && `'${dateformat(date, 'yyyy/mm/dd')}'`) || 'NULL'
    const toText = (text) => (text && `'${text}'`) || 'NULL'

    const usedFood = `
        INSERT INTO tbl_use_food (id_fo_uf, numuse_uf, id_cus_uf, dateuse_uf)
        VALUES ()
    `
    const result = await db.postgre.run(usedFood).catch((err) => {
        return res.status(500).json({
            err,
            code: 0,
        })
    })

    if (result.rows) {
        return res.status(200).json({
            data: result.rows,
            code: 1,
        })
    }
    return res.status(200).json({
        code: 0,
    })

})

module.exports = router
