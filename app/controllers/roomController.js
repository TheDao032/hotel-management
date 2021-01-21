const express = require('express')
const dateformat = require('dateformat')
const employee = require('../middlewares/employee')
const Regex = require('regex')

const router = express.Router()
const db = require('../models/db')

router.post('/search', (req, res) => {
    const { param } = req.body

    const toNumber = (number) => (number === '' || number === undefined || number === null || Number.isNaN(Number(number)) ? 'NULL' : number)
    const toText = (text) => (text && `'${text}'`) || 'NULL'
    const toDate = (date) => (date && !Number.isNaN(Number(Date.parse(date))) && `'${dateformat(date, 'yyyy/mm/dd')}'`) || 'NULL'
    const toBit = (bit) => `'${(bit && 1) || 0}'`
    const toArray = (array) => `${array ? `'{${array}}'` : 'NULL'}`

    const querySearch = param !== ''
    ? `
        SELECT *
            FROM tbl_room
            LEFT JOIN tbl_rank_room ON id_rr_room = id_rr
        WHERE
            rank_rr = '${toText(param.trim())}' OR numberpeople_room = '${toNumber(param.trim())}'
    `
    : `
        SELECT *
            FROM tbl_room
            LEFT JOIN tbl_rank_room on id_rr_room = id_rr
    `
})

module.exports = router
