const express = require('express')
const dateformat = require('dateformat')
const employee = require('../middlewares/employee')
const Regex = require('regex')

const router = express.Router()
const db = require('../models/db')

router.post('/info', async (req, res) => {
    const { id_emp, id_cus, id_room, number_people } = req.body

    const status = 0
    const toNumber = (number) => (number === '' || number === undefined || number === null || Number.isNaN(Number(number)) ? 'NULL' : number)
    const toDate = (date) => (date && !Number.isNaN(Number(Date.parse(date))) && `'${dateformat(date, 'yyyy/mm/dd')}'`) || 'NULL'
    const toText = (text) => (text && `'${text}'`) || 'NULL'
    const queryInsert = `
        INSERT INTO tbl_check_in (id_emp_ci, id_cus_ci, id_room_ci, numpeople_ci, status_ci)
        VALUES (
            ${toText(id_emp)},
            ${toNumber(id_cus)},
            ${toNumber(id_room)},
            ${toNumber(number_people)},
            ${toNumber(status)}
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

router.get('/search-status-ci', async (req, res) => {
    const { status } = req.body
    const toNumber = (number) => (number === '' || number === undefined || number === null || Number.isNaN(Number(number)) ? 'NULL' : number)
    const searchQuery = `
        SELECT *
            FROM tbl_check_in
        WHERE
            status_ci = ${toNumber(status)}
    `
    const searchResult = await db.postgre.run(searchQuery).catch((err) => {
        return res.status(500).json({
            err,
            code: 0,
        })
    })

    if (searchResult.rows) {
        return res.status(200).json({
            data: searchResult.rows,
            code: 1,
        })
    }
    return res.status(500).json({
        code: 0,
    })
})

router.get('/search-ci', async (req, res) => {
    const { param } = req.body
    const toNumber = (number) => (number === '' || number === undefined || number === null || Number.isNaN(Number(number)) ? 'NULL' : number)
    const toText = (text) => (text && `'${text}'`) || 'NULL'
    const searchQuery = `
        SELECT *
            FROM tbl_check_in
            LEFT JOIN tbl_customer ON id_cus = id_cus_ci
            LEFT JOIN tbl_room ON id_room = id_room_ci
        WHERE
            name_cus = ${toText(param)} OR phonenumber_cus = ${toText(param)} OR cardid_cus = ${toText(param)}
            OR name_room = ${toText(param)}
    `
    const searchResult = await db.postgre.run(searchQuery).catch((err) => {
        return res.status(500).json({
            err,
            code: 0,
        })
    })

    if (searchResult.rows) {
        return res.status(200).json({
            data: searchResult.rows,
            code: 1,
        })
    }
    return res.status(500).json({
        code: 0,
    })
})

module.exports = router
