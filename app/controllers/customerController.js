const express = require('express')
const dateformat = require('dateformat')
const employee = require('../middlewares/employee')
const Regex = require('regex')

const router = express.Router()
const db = require('../models/db')

router.post('/info', async (req, res) => {
    const { name, cardid, birth, phonenumber, foreigner } = req.body

    const status = 0
    const toNumber = (number) => (number === '' || number === undefined || number === null || Number.isNaN(Number(number)) ? 'NULL' : number)
    const toDate = (date) => (date && !Number.isNaN(Number(Date.parse(date))) && `'${dateformat(date, 'yyyy/mm/dd')}'`) || 'NULL'
    const toText = (text) => (text && `'${text}'`) || 'NULL'
    const birthDate = toDate(birth)
    const queryInsert = `
        INSERT INTO tbl_customer (name_cus, cardid_cus, birth_cus, phonenumber_cus, status_cus, isforeigner_cus)
        VALUES (
            ${toText(name)},
            ${toText(cardid.trim())},
            ${birthDate},
            ${toText(phonenumber.trim())},
            ${status},
            ${toNumber(foreigner)}
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
