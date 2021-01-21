const express = require('express')
const dateformat = require('dateformat')
const Regex = require('regex')
const employee = require('../middlewares/employee')

const router = express.Router()
const db = require('../models/db')

router.post('/search', async (req, res) => {
    const { param } = req.body

    const toNumber = (number) => (number === '' || number === undefined || number === null || Number.isNaN(Number(number)) ? 'NULL' : number)
    const toText = (text) => (text && `'${text}'`) || 'NULL'
    // const toDate = (date) => (date && !Number.isNaN(Number(Date.parse(date))) && `'${dateformat(date, 'yyyy/mm/dd')}'`) || 'NULL'
    // const toBit = (bit) => `'${(bit && 1) || 0}'`
    // const toArray = (array) => `${array ? `'{${array}}'` : 'NULL'}`

    const querySearch =
        param !== ''
            ? `
        SELECT *
            FROM tbl_room
            LEFT JOIN tbl_rank_room ON id_rr_room = id_rr
        WHERE
            rank_rr = ${toText(param.trim())} OR numpeople_room = ${toNumber(param.trim())}
    `
            : `
        SELECT *
            FROM tbl_room
            LEFT JOIN tbl_rank_room on id_rr_room = id_rr
    `

    const searchResult = await db.postgre.run(querySearch).catch((err) => {
        return res.status(500).json({
            err,
            code: 0,
        })
    })

    if (!searchResult.rows) {
        return res.status(200).json({
            code: 0,
        })
    }
    return res.status(200).json({
        data: searchResult.rows,
        code: 1,
    })
})

module.exports = router
