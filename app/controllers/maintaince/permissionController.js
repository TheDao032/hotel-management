const express = require('express')

const router = express.Router()
const moment = require('moment')
const db = require('../../models/db')
const { message } = require('../../common')

router.post('/list', function(req, res) {
    const { shain_cd, permission_cd } = req.body
    const query = `SELECT * FROM tbl_permission
     WHERE
       true
       ${shain_cd && ` AND position('${shain_cd.trim()}' in shain_cd) > 0`}
       ${permission_cd && ` AND permission_cd = '${permission_cd}' `}
     ORDER BY shain_cd DESC, start_date ASC`
    db.postgre
        .run(query)
        .then((result) => {
            if (result.rowCount === 0) return [[], []]

            const data = result.rows
            const shainCdList = data.map((item) => item.shain_cd)
            const query = `SELECT * FROM m_shain WHERE SHAIN_CD IN ('${shainCdList.join("','")}')`
            return Promise.all([db.oracle.run(query), data])
        })
        .then(([queryResult, data]) => {
            if (queryResult.length === 0) return []

            const shainMeiList = queryResult.rows.map((i) => {
                return {
                    shain_cd: i.shain_cd,
                    shain_mei: `${i.shain_sei || ''} ${i.shain_nm || ''}`,
                }
            })
            return data.filter((element) => {
                const foundShainMei = shainMeiList.find((mei) => element.shain_cd == mei.shain_cd)
                if (foundShainMei) {
                    element.shain_mei = foundShainMei.shain_mei
                    return true
                }
            })
        })
        .then((response) => {
            return res.status(200).json({
                success: true,
                data: response,
            })
        })
        .catch((err) => {
            return res.status(500).json({
                err,
            })
        })
})

router.post('/add', function(req, res) {
    // const start_date = req.body.start_date ? new Date(req.body.start_date).toLocaleDateString() : ''
    // const end_date = req.body.end_date ? new Date(req.body.end_date).toLocaleDateString() : ''
    const start_date = req.body.start_date ? moment(req.body.start_date).format('YYYY-MM-DD') : ''
    const end_date = req.body.end_date ? moment(req.body.end_date).format('YYYY-MM-DD') : ''
    const { shain_cd, permission_cd } = req.body
    const queryCheckDateConflict = `SELECT * FROM tbl_permission
    WHERE shain_cd = '${shain_cd}'
    AND NOT (
      start_date > '${end_date}' OR
      end_date < '${start_date}'
    )`
    db.postgre
        .run(queryCheckDateConflict)
        .then((ketqua) => {
            const query = `INSERT INTO tbl_permission(shain_cd, start_date, end_date, permission_cd)
         VALUES('${shain_cd}', '${start_date}', '${end_date}', '${permission_cd}') RETURNING *;`
            if (ketqua.rowCount !== 0) throw message.W017
            return db.postgre.run(query)
        })
        .then((result) => {
            if (result.rowCount === 0) throw 'Cannot insert new permission'
            return res.status(200).json({
                success: true,
            })
        })
        .catch((err) => {
            return res.status(500).json({
                success: false,
                message: err,
            })
        })
})

router.post('/update', function(req, res) {
    const { shain_cd, permission_cd, permission_id } = req.body
    const start_date = req.body.start_date ? new Date(req.body.start_date).toLocaleDateString() : ''
    const end_date = req.body.end_date ? new Date(req.body.end_date).toLocaleDateString() : ''
    const queryCheckDateConflict = `SELECT * FROM tbl_permission
     WHERE shain_cd = '${shain_cd}'
     AND permission_id <> '${permission_id}'
     AND NOT(
      start_date > '${end_date}'
      OR end_date < '${start_date}'
     )`
    db.postgre
        .run(queryCheckDateConflict)
        .then((ketqua) => {
            const query = `UPDATE tbl_permission
         SET start_date = '${start_date}',
           end_date = '${end_date}',
           permission_cd = '${permission_cd}'
         WHERE permission_id = '${permission_id}'
         RETURNING *`
            if (ketqua.rows.length !== 0) throw message.W017
            return db.postgre.run(query)
        })
        .then((result) => {
            if (result.rowCount === 0) throw 'Cannot update permission'
            return res.status(200).json({
                success: true,
            })
        })
        .catch((err) => {
            return res.status(500).json({
                success: false,
                message: err,
            })
        })
})

router.post('/delete', function(req, res) {
    const { permission_id } = req.body
    const query = `DELETE FROM tbl_permission WHERE permission_id = '${permission_id}'`
    db.postgre
        .run(query)
        .then((response) => {
            if (response.rowCount > 0) {
                return res.status(200).json({
                    success: true,
                })
            }
            throw 'Permission not found'
        })
        .catch((err) => {
            return res.status(500).json({
                success: false,
            })
        })
})

module.exports = router
