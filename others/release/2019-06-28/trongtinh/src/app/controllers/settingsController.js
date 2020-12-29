const router = require('express')()
const jwt = require('jsonwebtoken')
const http = require('http')
const db = require('../models/db')
const environments = require('../environments/environment')

const METABASE_SITE_URL = `localhost:${environments.PORT_METABASE}`
const METABASE_SECRET_KEY = '55f2cba4bc22c57fc43818cd4c225047e609e70d31a53de3ab34ac449c1088c5'

router.get('/get-chart', (req, res) => {
    const payloadPie = {
        resource: { question: 6 },
        params: {},
        exp: Math.round(Date.now() / 1000) + 10 * 60, // 10 minute expiration
    }
    const payloadLine = {
        resource: { question: 7 },
        params: {},
        exp: Math.round(Date.now() / 1000) + 10 * 60, // 10 minute expiration
    }
    const payloadBar = {
        resource: { question: 8 },
        params: {},
        exp: Math.round(Date.now() / 1000) + 10 * 60, // 10 minute expiration
    }
    const payloadDashBoard = {
        resource: { dashboard: 2 },
        params: {},
        exp: Math.round(Date.now() / 1000) + 10 * 60, // 10 minute expiration
    }
    const tokenBar = jwt.sign(payloadBar, METABASE_SECRET_KEY)
    const tokenPie = jwt.sign(payloadPie, METABASE_SECRET_KEY)
    const tokenLine = jwt.sign(payloadLine, METABASE_SECRET_KEY)
    const token4 = jwt.sign(payloadDashBoard, METABASE_SECRET_KEY)

    const iframeUrl = `${METABASE_SITE_URL}/embed/question/${tokenBar}#bordered=true&titled=true`
    const iframeUrlPie = `${METABASE_SITE_URL}/embed/question/${tokenPie}#bordered=true&titled=true`
    const iframeUrlLine = `${METABASE_SITE_URL}/embed/question/${tokenLine}#bordered=true&titled=true`
    const iframeUrlDashBoard = `${METABASE_SITE_URL}/embed/dashboard/${token4}#bordered=true&titled=true`

    return res.status(200).json({
        iframeUrl,
        iframeUrlPie,
        iframeUrlLine,
        iframeUrlDashBoard,
    })
})

router.get('/login-metabase', (req, res) => {
    const data = JSON.stringify({
        username: 'kensyuu@vn-cubesystem.com',
        password: 'Csv0202',
        'remote-address': 'true',
        request: 'true',
    })
    const options = {
        host: `${environments.ipServer}`,
        port: environments.PORT_METABASE,
        path: '/api/session/',
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(data),
        },
    }
    const httpreq = http.request(options, (response) => {
        response.setEncoding('utf8')
        response.on('data', (chunk) => {
            res.send(chunk)
        })
        response.on('end', () => {
            // res.send('ok')
        })
    })
    httpreq.write(data)
    httpreq.end()
})

router.post('/update-metabase', (req, res) => {
    const { sessionId, ki } = req.body
    //Update By TheDao
    // const query = `
    //     SELECT vk.kensyuu_mei,
    //         COUNT(tm.shain_cd) as number_shain_hm
    //     FROM view_kensyuu vk
    //     LEFT JOIN tbl_moushikomi tm ON tm.kensyuu_id = vk.kensyuu_id
    //         AND tm.kensyuu_sub_id = vk.kensyuu_sub_id
    //     WHERE vk.skill_hm_flag='1'
    //         AND kensyuu2ki(vk.kensyuu_id) = '${ki}'
    //     GROUP BY vk.kensyuu_mei`
    const query = `
        SELECT vk.kensyuu_mei,
            COUNT(tm.shain_cd) as number_shain_hm
        FROM view_kensyuu vk
        LEFT JOIN tbl_moushikomi tm ON tm.kensyuu_id = vk.kensyuu_id
            AND tm.kensyuu_sub_id = vk.kensyuu_sub_id
        WHERE kensyuu2ki(vk.kensyuu_id) = '${ki}'
        GROUP BY vk.kensyuu_mei`
    //End Update By TheDao
    const data = JSON.stringify({
        'card-updates': 'true',
        dataset_query: {
            database: 3,
            type: 'native',
            native: {
                query,
            },
        },
    })
    const arrChart = [6, 7, 8]
    arrChart.forEach((element) => {
        const options = {
            host: `${environments.ipServer}`,
            port: environments.PORT_METABASE,
            path: `/api/card/${element}`,
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(data),
                'X-Metabase-Session': `${sessionId}`,
            },
        }
        const httpreq = http.request(options, (response) => {
            response.setEncoding('utf8')
            response.on('data', (chunk) => {
                res.send(chunk)
            })
            response.on('end', () => {
                // res.send('ok')
            })
        })
        httpreq.write(data)
        httpreq.end()
    })
})

router.post('/get-detail-mail-company', (req, res) => {
    // const { data } = req.body

    const query = `
        SELECT *
        FROM tbl_kyouiku_shukankikan
    `
    db.postgre
        .run(query)
        .then(() => {
            db.postgre.run(query).then((result1) => {
                return res.status(200).json({
                    data: result1.rows,
                    code: 0,
                })
            })
        })
        .catch((err) => {
            res.status(500).json({
                data: [],
                err,
            })
        })
})

router.post('/get-detail-from-mail', (req, res) => {
    // const { id } = req.body
    const query = `
        SELECT *
        FROM tbl_mail_template
    `
    db.postgre
        .run(query)
        .then((result) => {
            return res.status(200).json({
                data: result.rows[0],
            })
        })
        .catch((err) => {
            res.status(500).json({
                data: [],
                err,
            })
        })
})

router.post('/get-detail-mail', (req, res) => {
    const { id } = req.body
    const query = `
        SELECT *
        FROM tbl_mail_template
        WHERE template_id = '${id}'
    `
    db.postgre
        .run(query)
        .then((result) => {
            return res.status(200).json({
                data: result.rows[0],
            })
        })
        .catch((err) => {
            res.status(500).json({
                data: [],
                err,
            })
        })
})

router.post('/edit-config', (req, res) => {
    const { data } = req.body
    const updateData = []
    Object.keys(data).forEach((key) => {
        const type = typeof data[key]
        updateData.push(`${key} = ${type === 'string' ? `'${data[key]}'` : `${data[key]}`}`)
    })

    const sqlSelect = `
        SELECT *
        FROM tbl_mail_config
        WHERE id = '1'
    `
    const sqlUpdate = `
        UPDATE tbl_mail_config
        SET ${updateData.join(', ')}
        WHERE id = '1'
    `

    const sqlInsert = `
        insert into tbl_mail_config(host,port,secure,usermail_auth,passmail_auth)
        values('${data.host}','${data.port}','${data.secure}','${data.usermail_auth}','${data.passmail_auth}')
    `

    db.postgre
        .run(sqlSelect)
        .then((result) => {
            if (result.rows.length === 1) {
                db.postgre
                    .run(sqlUpdate)
                    .then(() => {
                        return res.status(200).json({
                            code: 0,
                        })
                    })
                    .catch((error) => {
                        return res.status(500).json({
                            code: 1,
                            error,
                        })
                    })
            }
            if (result.rows.length === 0) {
                db.postgre
                    .run(sqlInsert)
                    .then(() => {
                        return res.status(200).json({
                            code: 0,
                        })
                    })
                    .catch((error) => {
                        return res.status(500).json({
                            code: 1,
                            error,
                        })
                    })
            }
        })
        .catch((err) => {
            return res.status(500).json({
                code: 2,
                data: [],
                err,
            })
        })
})

router.post('/get-config', (req, res) => {
    const sql = `
        SELECT *
        FROM tbl_mail_config
    `
    db.postgre
        .run(sql)
        .then((result) => {
            if (result.rows.length === 0) {
                return res.status(200).json({
                    code: 2,
                    data: [],
                })
            }
            return res.status(200).json({
                code: 0,
                data: result.rows[0],
            })
        })
        .catch((err) => {
            return res.status(500).json({
                code: 1,
                data: [],
                err,
            })
        })
})

router.post('/save-mail', (req, res) => {
    const { data } = req.body
    const { template_id } = data
    delete data.template_id
    if (template_id === 'moushikomi_kyouiku') {
        const updateData = []
        Object.keys(data).forEach((key) => {
            const type = typeof data[key]
            updateData.push(`${key} = ${type === 'string' ? `'${data[key]}'` : `${data[key]}`}`)
        })

        const sql = `
            UPDATE tbl_mail_template
            SET ${updateData.join(', ')}
            WHERE template_id like 'moushikomi%'
        `
        db.postgre
            .run(sql)
            .then(() => {
                return res.status(200).json({
                    code: 0,
                })
            })
            .catch((error) => {
                return res.status(500).json({
                    code: 1,
                    error,
                })
            })
    }
    if (template_id === 'cancel_kyouiku') {
        const updateData = []
        Object.keys(data).forEach((key) => {
            const type = typeof data[key]
            updateData.push(`${key} = ${type === 'string' ? `'${data[key]}'` : `${data[key]}`}`)
        })
        const sql = `
            UPDATE tbl_mail_template
            SET ${updateData.join(', ')}
            WHERE template_id like 'cancel%'
        `
        db.postgre
            .run(sql)
            .then(() => {
                return res.status(200).json({
                    code: 0,
                })
            })
            .catch((error) => {
                return res.status(500).json({
                    code: 1,
                    error,
                })
            })
    }
    if (template_id === 'early_kyouiku') {
        const updateData = []
        Object.keys(data).forEach((key) => {
            const type = typeof data[key]
            updateData.push(`${key} = ${type === 'string' ? `'${data[key]}'` : `${data[key]}`}`)
        })
        const sql = `
            UPDATE tbl_mail_template
            SET ${updateData.join(', ')}
            WHERE template_id like 'early%'
        `
        db.postgre
            .run(sql)
            .then(() => {
                return res.status(200).json({
                    code: 0,
                })
            })
            .catch((error) => {
                return res.status(500).json({
                    code: 1,
                    error,
                })
            })
    }
})

router.post('/get-color-setting', (req, res) => {
    const query = `
        SELECT *
        FROM tbl_setting
    `
    db.postgre
        .run(query)
        .then((result) => {
            return res.status(200).json({
                data: result.rows[0],
            })
        })
        .catch((err) => {
            res.status(500).json({
                data: [],
                err,
            })
        })
})

router.post('/update-recommends', (req, res) => {
    const data = req.body
    const query = `
        UPDATE public.tbl_recommend_template
        SET is_check=${data.is_check}
        WHERE column_id='${data.column_id}';
    `
    db.postgre
        .run(query)
        .then(() => {
            return res.status(200).json({
                code: 0,
            })
        })
        .catch((err) => {
            res.status(500).json({
                data: [],
                err,
            })
        })
})

router.post('/get-time-setting-mail', (req, res) => {
    const query = `
        SELECT  *
        FROM public.tbl_setting;
    `
    db.postgre
        .run(query)
        .then((rs) => {
            const data = rs.rows[0]
            res.status(200).json({
                data,
            })
        })
        .catch((err) =>
            res.status(500).json({
                err,
            })
        )
})

router.post('/edit-time-setting-mail', (req, res) => {
    const { data } = req.body
    const query = `
        UPDATE public.tbl_setting
        SET  saving_day_send_mail='${data}';
    `
    db.postgre
        .run(query)
        .then((rs) => {
            res.status(200).json({
                code: 0,
            })
        })
        .catch((err) =>
            res.status(500).json({
                code: 1,
            })
        )
})

router.post('/edit-detail-from-mail', (req, res) => {
    const { data } = req.body

    const sqlUpdate = `
        UPDATE public.tbl_mail_template
        SET template_from= true, template_from_naiyou= '${data}'
    `
    db.postgre
        .run(sqlUpdate)
        .then((rs) => {
            res.status(200).json({
                code: 0,
            })
        })
        .catch((err) => {
            res.status(500).json({
                code: 1,
            })
        })
})

router.post('/edit-mail-shukankikhan', (req, res) => {
    const { data } = req.body
    const query = `
        UPDATE public.tbl_kyouiku_shukankikan
        SET name_shukankikan='${data.name_shukankikan}', mail_shukankikan=${data.mail_shukankikan ? `'${data.mail_shukankikan}'` : 'mail_shukankikan'}
        WHERE id_kyouiku_shukankikan=${data.id_kyouiku_shukankikan};
    `
    db.postgre
        .run(query)
        .then(() => {
            return res.status(200).json({
                code: 0,
            })
        })
        .catch((err) => {
            res.status(500).json({
                data: [],
                err,
            })
        })
})

router.post('/get-detail-time-search', (req, res) => {
    const query = `
        select * from public.tbl_setting
    `
    db.postgre
        .run(query)
        .then((rs) => {
            return res.status(200).json({
                code: 0,
                data: rs.rows[0],
            })
        })
        .catch((err) => {
            res.status(500).json({
                data: [],
                err,
            })
        })
})

router.post('/update-time-search', (req, res) => {
    const { time } = req.body
    const query = `
        UPDATE public.tbl_setting
        SET saving_search_time= ${time}
        --WHERE setting_id=1;
    `
    db.postgre
        .run(query)
        .then((rs) => {
            return res.status(200).json({
                code: 0,
            })
        })
        .catch((err) => {
            res.status(500).json({
                code: 1,
            })
        })
})

router.get('/get-recommends', (req, res) => {
    const query = `
        SELECT * FROM public.tbl_recommend_template
        ORDER BY id
    `
    db.postgre
        .run(query)
        .then((rs) => {
            const data = rs.rows
            res.status(200).json({
                data,
            })
        })
        .catch((err) =>
            res.status(500).json({
                err,
            })
        )
})

router.post('/update-day-send-mail', (req, res) => {
    // update mail
    const { data } = req.body
    if (data.time < 0) {
        return res.status(500).json({
            code: 5,
        })
    }
    const queryUpdate = `
    UPDATE public.tbl_setting
    SET saving_day_send_mail= ${data.time ? `${data.time}` : 0} returning *;
    `
    db.postgre
        .run(queryUpdate)
        .then((rs) => {
            return res.status(200).json({
                code: 0,
            })
        })
        .catch((err) => {
            return res.status(500).json({
                code: 1,
            })
        })
})

router.post('/update-template-from', (req, res) => {
    // update template from
    const { data } = req.body
    const queryUpdate = `
        UPDATE public.tbl_mail_template
        SET template_from= true, template_from_naiyou= '${data.template_from_naiyou}';
    `
    db.postgre
        .run(queryUpdate)
        .then((rs) => {
            return res.status(200).json({
                code: 0,
            })
        })
        .catch((err) => {
            return res.status(500).json({
                code: 1,
            })
        })
})

router.post('/update-mail-shukankikan', (req, res) => {
    // update mail
    const { data } = req.body

    const arrData = data.mailFormData
    let sqlFormMail = ''
    arrData.forEach((e) => {
        sqlFormMail += `(${e.id_kyouiku_shukankikan}, '${e.name_shukankikan}', '${e.mail_shukankikan}'),`
    })
    const query = `
        UPDATE tbl_kyouiku_shukankikan
        AS u SET
            name_shukankikan = u2.name_shukankikan,
            mail_shukankikan = u2.mail_shukankikan
        FROM (
            VALUES ${sqlFormMail.slice(0, -1)})
        AS u2(id_kyouiku_shukankikan, name_shukankikan, mail_shukankikan)
        WHERE u2.id_kyouiku_shukankikan = u.id_kyouiku_shukankikan;

    `
    db.postgre
        .run(query)
        .then((rs) => {
            return res.status(200).json({
                code: 0,
            })
        })
        .catch((err) => {
            return res.status(500).json({
                code: 1,
            })
        })
})

router.post('/update-config-mail', (req, res) => {
    // update config mail
    const { data } = req.body
    let query = ''
    if (!data.id) {
        query += `
        INSERT INTO tbl_mail_config(host,port,secure,usermail_auth,passmail_auth)
        VALUES('${data.host}',${data.port},${data.secure},'${data.name_user}','${data.pass_user}')
        `
    } else {
        query += `
        UPDATE public.tbl_mail_config
        SET host='${data.host}', port=${data.port}, secure=${data.secure}, usermail_auth='${data.name_user}', passmail_auth='${data.pass_user}'
        WHERE id=${data.id};`
    }
    db.postgre
        .run(query)
        .then((rs) => {
            return res.status(200).json({
                code: 0,
            })
        })
        .catch((err) => {
            return res.status(500).json({
                code: 1,
            })
        })
})
module.exports = router
