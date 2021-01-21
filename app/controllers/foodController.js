const express = require('express')
const dateformat = require('dateformat')
// const employee = require('../middlewares/employee')
// const Regex = require('regex')
const foodService = require('../services/foodService')

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

router.post('/add-used-food', async (req, res) => {
    const { id_cus, id_food, number_food, date_create } = req.body

    const toNumber = (number) => (number === '' || number === undefined || number === null || Number.isNaN(Number(number)) ? 'NULL' : number)
    const toDate = (date) => (date && !Number.isNaN(Number(Date.parse(date))) && `'${dateformat(date, 'yyyy/mm/dd')}'`) || 'NULL'
    // const toText = (text) => (text && `'${text}'`) || 'NULL'

    const usedFood = `
        INSERT INTO tbl_use_food (id_fo_uf, numuse_uf, id_cus_uf, dateuse_uf)
        VALUES (
            ${toNumber(id_cus)},
            ${toNumber(id_food)},
            ${toNumber(number_food)},
            ${toDate(date_create)}
        )
    `
    await db.postgre.run(usedFood).catch((err) => {
        return res.status(500).json({
            err,
            code: 0,
        })
    })

    return res.status(200).json({
        code: 1,
    })
})

router.post('/cost', async (req, res) => {
    const { id_cus } = req.body
    const usedFood = `
        SELECT id_fo_uf, numuse_uf
            FROM tbl_use_food
        WHERE id_cus_uf = '${id_cus}'
    `

    const usedFoodResult = db.postgre.run(usedFood).catch((err) => {
        return res.status(500).json({
            err,
            code: 0,
        })
    })

    if (!usedFoodResult.rows) {
        return res.status(500).json({
            code: 0,
        })
    }

    let sumPrice = 0
    for (let i = 0; i < usedFoodResult.rows.length; i += 1) {
        sumPrice += foodService.costFunc(usedFoodResult.rows[i].id_fo_uf, usedFoodResult.rows[i].numuse_uf)
    }
    return res.status(200).json({
        sumPrice,
    })
})

router.post('/add-food', async (req, res) => {
    const { name, price, quantity } = req.body

    const toNumber = (number) => (number === '' || number === undefined || number === null || Number.isNaN(Number(number)) ? 'NULL' : number)
    const toText = (text) => (text && `'${text}'`) || 'NULL'

    const status = 1
    const addQuery = `
        INSERT INTO tbl_food (name_fo, price_fo, quantity_fo, status_fo)
        VALUES (
            ${toText(name)},
            ${toNumber(price)},
            ${toNumber(quantity)},
            ${status}
        )
    `

    await db.postgre.run(addQuery).catch((err) => {
        return res.status(500).json({
            err,
            code: 0,
        })
    })

    return res.status(200).json({
        code: 1,
    })
})

router.post('/change', async (req, res) => {
    const { id_fo, name, price, quantity } = req.body

    const toNumber = (number) => (number === '' || number === undefined || number === null || Number.isNaN(Number(number)) ? 'NULL' : number)
    const toText = (text) => (text && `'${text}'`) || 'NULL'

    let status = 1
    if (quantity === 0) {
        status = 0
    }

    const updateQuery = `
        UPDATE tbl_food
        SET name_fo = ${toNumber(name)},
            price_fo = ${toNumber(price)},
            quantity_fo = ${toText(quantity)},
            status_fo = ${status}
        WHERE id_fo = ${toNumber(id_fo)}
    `
    await db.postgre.run(updateQuery).catch((err) => {
        return res.status(500).json({
            err,
            code: 0,
        })
    })
    return res.status(200).json({
        code: 1,
    })
})

module.exports = router
