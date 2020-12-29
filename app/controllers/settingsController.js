const router = require('express')()
const jwt = require('jsonwebtoken')
const http = require('http')
const graph = require('@microsoft/microsoft-graph-client')
const db = require('../models/db')
const environments = require('../environments/environment')
const authHelper = require('../middlewares/authentication')

const METABASE_SITE_URL = `http://${environments.ipServer}:${environments.PORT_METABASE}`
const METABASE_SECRET_KEY = `${environments.SECRET_KEY_METABASE}`

router.get('/get-chart', (req, res) => {
    const payloadPie = {
        resource: { question: 3 },
        params: {},
        exp: Math.round(Date.now() / 1000) + 10 * 60, // 10 minute expiration
    }
    const payloadLine = {
        resource: { question: 2 },
        params: {},
        exp: Math.round(Date.now() / 1000) + 10 * 60, // 10 minute expiration
    }
    const payloadBar = {
        resource: { question: 1 },
        params: {},
        exp: Math.round(Date.now() / 1000) + 10 * 60, // 10 minute expiration
    }
    const payloadDashBoard = {
        resource: { dashboard: 1 },
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
        payloadBar,
        payloadLine,
        payloadPie,
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
            //
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
    const { sessionId, ki, idChart } = req.body
    let query = ``
    // Update By TheDao
    if (idChart === 10) { // TC Bar
        // query = `SELECT COUNT(tm.shain_cd) as 社員数, COUNT(vk.kensyuu_id) as 研修数, 'TC' as 列名
        //     FROM view_kensyuu vk
        //     LEFT JOIN tbl_moushikomi tm ON tm.kensyuu_id = vk.kensyuu_id AND tm.kensyuu_sub_id = vk.kensyuu_sub_id
        //     WHERE vk.skill_tc_flag='1' AND kensyuu2ki(vk.kensyuu_id) = '${ki}'`
        query = `SELECT COUNT(tm.shain_cd) as 社員数, COUNT(vk.kensyuu_id) as 研修数
            FROM view_kensyuu vk
            LEFT JOIN tbl_moushikomi tm ON tm.kensyuu_id = vk.kensyuu_id AND tm.kensyuu_sub_id = vk.kensyuu_sub_id
            WHERE kensyuu2ki(vk.kensyuu_id) = '${ki}'`
    } else if (idChart === 11) { // MG Bar
        // query = `SELECT COUNT(tm.shain_cd) as 社員数, COUNT(vk.kensyuu_id) as 研修数, 'MG' AS 列名
        //     FROM view_kensyuu vk
        //     LEFT JOIN tbl_moushikomi tm ON tm.kensyuu_id = vk.kensyuu_id AND tm.kensyuu_sub_id = vk.kensyuu_sub_id
        //     WHERE vk.skill_mg_flag='1' AND kensyuu2ki(vk.kensyuu_id) = '${ki}'`
        query = `SELECT COUNT(tm.shain_cd) as 社員数, COUNT(vk.kensyuu_id) as 研修数
            FROM view_kensyuu vk
            LEFT JOIN tbl_moushikomi tm ON tm.kensyuu_id = vk.kensyuu_id AND tm.kensyuu_sub_id = vk.kensyuu_sub_id
            WHERE AND kensyuu2ki(vk.kensyuu_id) = '${ki}'`
    } else if (idChart === 9) { // HM Bar
        // query = `SELECT COUNT(tm.shain_cd) as 社員数, COUNT(vk.kensyuu_id) as 研修数, 'HM' as 列名
        //     FROM view_kensyuu vk
        //     LEFT JOIN tbl_moushikomi tm ON tm.kensyuu_id = vk.kensyuu_id AND tm.kensyuu_sub_id = vk.kensyuu_sub_id
        //     WHERE vk.skill_hm_flag='1' AND kensyuu2ki(vk.kensyuu_id) = '${ki}'`
        query = `SELECT COUNT(tm.shain_cd) as 社員数, COUNT(vk.kensyuu_id) as 研修数
            FROM view_kensyuu vk
            LEFT JOIN tbl_moushikomi tm ON tm.kensyuu_id = vk.kensyuu_id AND tm.kensyuu_sub_id = vk.kensyuu_sub_id
            WHERE kensyuu2ki(vk.kensyuu_id) = '${ki}'`
    } else if (idChart === 12) { // OA Bar
        // query = `SELECT COUNT(tm.shain_cd) 社員数, COUNT(vk.kensyuu_id) as 研修数, 'OA' as 列名
        //     FROM view_kensyuu vk
        //     LEFT JOIN tbl_moushikomi tm ON tm.kensyuu_id = vk.kensyuu_id AND tm.kensyuu_sub_id = vk.kensyuu_sub_id
        //     WHERE vk.skill_oa_flag='1' AND kensyuu2ki(vk.kensyuu_id) = '${ki}'`
        query = `SELECT COUNT(tm.shain_cd) 社員数, COUNT(vk.kensyuu_id) as 研修数
            FROM view_kensyuu vk
            LEFT JOIN tbl_moushikomi tm ON tm.kensyuu_id = vk.kensyuu_id AND tm.kensyuu_sub_id = vk.kensyuu_sub_id
            WHERE kensyuu2ki(vk.kensyuu_id) = '${ki}'`
    } else {
        // query = `SELECT vk.kensyuu_mei AS 研修名,
        //         COUNT(tm.shain_cd) AS 社員数
        //     FROM view_kensyuu vk
        //     LEFT JOIN tbl_moushikomi tm ON tm.kensyuu_id = vk.kensyuu_id
        //         AND tm.kensyuu_sub_id = vk.kensyuu_sub_id
        //     WHERE vk.skill_hm_flag='1'
        //         AND kensyuu2ki(vk.kensyuu_id) = '${ki}'
        //     GROUP BY vk.kensyuu_mei`
        query = `SELECT vk.kensyuu_mei AS 研修名,
                COUNT(tm.shain_cd) AS 社員数
            FROM view_kensyuu vk
            LEFT JOIN tbl_moushikomi tm ON tm.kensyuu_id = vk.kensyuu_id
                AND tm.kensyuu_sub_id = vk.kensyuu_sub_id
            WHERE kensyuu2ki(vk.kensyuu_id) = '${ki}'
            GROUP BY vk.kensyuu_mei`
    }
    // End Update By TheDao
    

    const data = JSON.stringify({
        'card-updates': 'true',
        dataset_query: {
            database: 2,
            type: 'native',
            native: {
                query,
            },
        },
    })
    const options = {
        host: `${environments.ipServer}`,
        port: environments.PORT_METABASE,
        path: `/api/card/${idChart}`,
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
    })
    httpreq.write(data)
    httpreq.end()
})

router.post('/get-detail-mail-company', (req, res) => {
    /*
        - Lấy tất cả các cột của bảng tbl_kyouiku_shukankikan ở postgre
   */

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
    /*
        - Lấy hàng đầu tiên của tbl_mail_template của postgre
   */
    const query = `
        SELECT *
        FROM tbl_mail_template
    `
    db.postgre
        .run(query)
        .then((result) => {
            return res.status(200).json({
                data: result.rows[0],
                sub_mail: environments.subMail,
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
    /*
        - Tìm hàng đầu tiên trong bảng tbl_mail_template của postgre với id được gởi từ client
    */
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

router.post('/get-config', (req, res) => {
    /*
        - Lấy hàng đầu tiên trong bảng tbl_mail_config ở postgre

    */
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
    /*
- Dữ liệu lấy từ client bao gồm template_id, data.
- Nếu template_id trùng với tên nào thì sẽ gọi hàm đó.
- Và thực hiện update bảng tbl_mail_template ở postgre với template_id trùng với templapte được gọi.

*/

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
    if (template_id === 'end_nittei') {
        const updateData = []
        Object.keys(data).forEach((key) => {
            const type = typeof data[key]
            updateData.push(`${key} = ${type === 'string' ? `'${data[key]}'` : `${data[key]}`}`)
        })
        const sql = `
            UPDATE tbl_mail_template
            SET ${updateData.join(', ')}
            WHERE template_id = 'end_nittei'
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
    if (template_id === 'start_nittei') {
        const updateData = []
        Object.keys(data).forEach((key) => {
            const type = typeof data[key]
            updateData.push(`${key} = ${type === 'string' ? `'${data[key]}'` : `${data[key]}`}`)
        })
        const sql = `
            UPDATE tbl_mail_template
            SET ${updateData.join(', ')}
            WHERE template_id = 'start_nittei'
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
    let query = `SELECT 1;`
    data.forEach((element) => {
        query += `
        UPDATE public.tbl_recommend_template
        SET is_check=${element.is_check}
        WHERE column_id='${element.column_id}';
        `
    })
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
    /*
        - Thực hiện lấy hàng đầu tiên trong bảng tbl_setting của postgre
    */
    const query = `
        SELECT  *
        FROM public.tbl_setting;
    `
    db.postgre
        .run(query)
        .then((rs) => {
            const data = rs.rows[0]
            return res.status(200).json({
                data,
            })
        })
        .catch((err) => {
            return res.status(500).json({
                err,
            })
        })
})

router.post('/get-detail-time-search', (req, res) => {
    /*
        - Thực hiện lấy cột đầu tiên trong bảng tbl_setting
    */
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
            return res.status(500).json({
                data: [],
                err,
            })
        })
})

router.post('/update-time-search', (req, res) => {
    /*
        - Dữ liệu time được lấy từ client
        - Thực hiện update cột saving_search_time ở bảng tbl_setting của postgre
    */
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
            return res.status(500).json({
                code: 1,
            })
        })
})

router.get('/get-recommends', (req, res) => {
    //Update By TheDao
    // const query = `
    //     SELECT * FROM public.tbl_recommend_template
    //     ORDER BY id 
    // `
    const query = `
        SELECT * FROM public.tbl_recommend_template
        WHERE column_id != 'skill_list'
        ORDER BY id 
    `
    //End Update By TheDao
    db.postgre
        .run(query)
        .then((rs) => {
            const data = rs.rows
            return res.status(200).json({
                data,
            })
        })
        .catch((err) => {
            return res.status(500).json({
                err,
            })
        })
})

router.post('/update-day-send-mail', (req, res) => {
    /*
        - Dữ liệu time được lấy từ client
        - Thực hiện update cột saving_day_send_mail ở bảng tbl_setting của postgre

   */
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
    /*
        - Dữ liệu template_from_naiyou được lấy từ client
        - Thực hiện update 2 cột template_from, template_from_naiyou với giá trị template_from= true,
            template_from_naiyou = chính dữ liệu được lấy từ client

   */
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
    /*
        - Dữ liệu data.mailFormData lấy từ client
        - Thực hiện update bảng tbl_kyouiku_shukankikan ở postgre nhiều dòng dữ liệu cùng 1 lúc
    */
    const { data } = req.body

    const arrData = data.mailFormData
    let sqlFormMail = ''
    arrData.forEach((e) => {
        sqlFormMail += `(${e.id_kyouiku_shukankikan}, '${e.name_shukankikan}', ${e.mail_shukankikan ? `'${e.mail_shukankikan}'` : null}),`
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
    /*
        - Dữ liệu id, host, port, secure, name_user, pass_user được lấy từ client
        - Thực hiện update hoặc insert bảng table_mail_config
   */
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

router.post('/set-default-mail', (req, res) => {
    const { input } = req.body
    const query = `
        UPDATE tbl_kyouiku_shukankikan
        SET default_mail = '${input}'
    `
    db.postgre
        .run(query)
        .then(() => {
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

/* OUTLOOK CALENDAR API */
/* GET /calendar */
router.post('/get-events', async (req, res) => {
    // const parms = { title: 'Calendar', active: { calendar: true } }
    const { input, nittei_data } = req.body
    //
    const accessToken = input ? await authHelper.getAccessToken(input.data, res) : ''
    const userName = input ? jwt.decode(input.data.id_token) : ''
    if (accessToken && userName) {
        const user = userName

        // Initialize Graph client
        const client = graph.Client.init({
            authProvider: (done) => {
                done(null, accessToken)
            },
        })

        // Set start of the calendar view to today at midnight
        // const start = new Date(new Date().setHours(0, 0, 0))
        const start = nittei_data ? nittei_data.nittei_from : new Date(new Date().setHours(0, 0, 0)).toISOString()
        // Set end of the calendar view to 7 days from start
        // const end = new Date(new Date(start).setDate(start.getDate() + 7))
        const end = nittei_data ? nittei_data.nittei_to : new Date(new Date(start).setDate(new Date().getDate() + 7)).toISOString()

        try {
            // Get the first 10 events for the coming week
            const result = await client
                .api(`/me/calendarView?startDateTime=${start}&endDateTime=${end}`)
                .header('Prefer', 'outlook.timezone="Pacific Standard Time"')
                .top(10)
                .select('subject,body,bodyPreview,organizer,attendees,start,end,location')
                .orderby('start/dateTime DESC')
                .get()

            // parms.debug = `Graph request returned: ${JSON.stringify(result, null, 2)}`;

            // parms.events = result.value
            // res.render('calendar', parms)
            res.status(200).json({
                code: 0,
                data: {
                    user,
                    result: result.value,
                },
            })
            //
        } catch (err) {
            // parms.message = 'Error retrieving events'
            // parms.error = { status: `${err.code}: ${err.message}` }
            // parms.debug = JSON.stringify(err.body, null, 2)
            // res.render('error', parms)
            res.status(400).json({
                code: 1,
                data: {
                    message: 'Error retrieving events',
                    error: { status: `${err.code}: ${err.message}` },
                    debug: JSON.stringify(err.body, null, 2),
                },
            })
        }
    } else {
        // Redirect to home
        // res.redirect('/settings/calendar')
    }
    // res.render('index', parms);
})

router.post('/create-or-update-event', async (req, res) => {
    // Construct email object.
    const { input, eventData, shain, eventList, status } = req.body
    const accessToken = input !== '' ? await authHelper.getAccessToken(input.data, res) : ''
    const userName = input !== '' ? jwt.decode(input.data.id_token) : ''

    if (accessToken && userName) {
        const user = userName
        let { kensyuu_mei } = eventData
        const original_kensyuu_mei = eventData.kensyuu_mei
        if (eventData.kensyuu_id.substring(3, 4) === '5' || eventData.kensyuu_id.substring(3, 4) === '6') {
            kensyuu_mei = `（確定）${kensyuu_mei}`
        } else {
            kensyuu_mei = `（仮）${kensyuu_mei}`
        }
        // console.log('status', status)
        if (status !== null && (status !== 0 || status !== 3)) kensyuu_mei = original_kensyuu_mei
        const event = {
            subject: `${kensyuu_mei}-${eventData.nittei_id}`,
            body: {
                contentType: 'HTML',
                content: eventData.kensyuu_gaiyou,
            },
            start: {
                dateTime: eventData.nittei_from,
                timeZone: 'Pacific Standard Time',
            },
            end: {
                dateTime: eventData.nittei_to,
                timeZone: 'Pacific Standard Time',
            },
            location: {
                displayName: eventData.basho,
            },
            attendees: eventList ? eventList.attendees : [],
        }
        if (shain) {
            event.attendees.push({ emailAddress: { address: shain.mail_address, name: shain.shain_mei }, type: 'required' })
        }

        // CREATE EVENT
        if (eventList) {
            try {
                const client = graph.Client.init({
                    authProvider: (done) => {
                        done(null, accessToken)
                    },
                })
                const response1 = await client.api(`/me/events/${eventList.id}`).patch(event)
                //
                return res.status(200).json({
                    code: 0,
                    type: 'update',
                })
            } catch (error) {
                return res.status(400).json({
                    code: 1,
                    type: 'update',
                    error,
                })
            }
        } // UPDATE EVENT
        else {
            try {
                const client = graph.Client.init({
                    authProvider: (done) => {
                        done(null, accessToken)
                    },
                })

                const response = await client.api('/me/events').post(event, (err, result) => {
                    return res.status(200).json({
                        code: 0,
                        type: 'insert',
                    })
                    // res.redirect('/settings/calendar')
                })
            } catch (error) {
                return res.status(400).json({
                    code: 1,
                    type: 'insert',
                    error,
                })
            }
        }
    } else {
        return res.status(401).json({
            code: 2,
            type: 'Unauthorized',
        })
    }
})

router.post('/delete-event', async (req, res) => {
    const { input, eventId } = req.body

    const accessToken = input !== '' ? await authHelper.getAccessToken(input.data, res) : ''
    const userName = input !== '' ? jwt.decode(input.data.id_token) : ''

    if (accessToken && userName) {
        // const id = `AQMkADAwATM3ZmYAZS0wMAA3NwAtYTdkMy0wMAItMDAKAEYAAAPqR5bKiGK0QrNtfi-FshZDBwAZtrx6Vix6Spb4Svinu3QWAAACAQ0AAAAZtrx6Vix6Spb4Svinu3QWAAK4w_EjAAAA`
        try {
            const client = graph.Client.init({
                authProvider: (done) => {
                    done(null, accessToken)
                },
            })

            const response = await client.api(`/me/events/${eventId}`).delete()
            //
            res.status(200).json({
                code: 0,
                type: 'delete',
            })
        } catch (error) {
            console.error(error)
            res.status(400).json({
                code: 1,
                type: 'delete',
                error,
            })
        } finally {
            res.redirect('/settings/calendar')
        }
    }
})
const mapDate = (item) => {
    const itemDup = item
    const { start, end } = itemDup
    if (start && Date.parse(start)) itemDup.start = new Date(start).toISOString()
    if (end && Date.parse(end)) itemDup.end = new Date(end).toISOString()
    return itemDup
}
router.post('/all-event', (req, res) => {})
router.post('/update-event', (req, res) => {
    const { shain_cd } = req.user
    const { data } = req.body
    const sqlSelect = `
            SELECT * FROM tbl_event WHERE event_id = ${data.event_id} and user_id = '${shain_cd}'
    `

    db.postgre
        .run(sqlSelect)
        .then((rs1) => {
            if (rs1.rows.length === 0) {
                const sqlInsert = `
                INSERT INTO public.tbl_event(
                    event_title, start_ts, end_ts, event_note,user_id)
                 VALUES ('${data.event_title}','${data.start_ts}', '${data.end_ts}','${data.event_note}','${shain_cd}') RETURNING *;
          `
                db.postgre
                    .run(sqlInsert)
                    .then((rs2) => {
                        if (rs2.rows.length === 0) {
                            return res.status(500).json({
                                code: 2,
                            })
                        }
                        return res.status(200).json({
                            code: 3,
                            type: 'insert',
                        })
                    })
                    .catch(() => {
                        return res.status(500).json({
                            code: 8,
                        })
                    })
            }
            if (rs1.rows.length !== 0) {
                const sqlUpdate = `
                UPDATE tbl_event
                SET event_title = '${data.event_title}', event_note = '${data.event_note}', start_ts = '${data.start_ts}', end_ts = '${data.end_ts}'
                WHERE event_id = ${data.event_id};
            `
                db.postgre
                    .run(sqlUpdate)
                    .then((rs3) => {
                        return res.status(200).json({
                            code: 0,
                            type: 'update',
                        })
                    })
                    .catch((err) => {
                        res.status(500).json({
                            code: 1,
                        })
                    })
            }
        })
        .catch(() => {
            return res.status(500).json({
                code: 'ecec',
            })
        })
})
router.post('/delete-event-id', (req, res) => {
    const { id } = req.body
    const query = `DELETE FROM tbl_event WHERE event_id = ${id}; `

    if (!id) {
        return res.status(200).json({
            code: 2,
        })
    }
    if (id) {
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
    }
})
router.post('/event-list', (req, res) => {
    const { shain_cd } = req.user
    // const { filter, user } = req.body
    // const { event_title, start_ts, end_ts, event_note } = filter

    // const arrCategory = ''
    const query = `select * from tbl_event where user_id = '${shain_cd}'`
    db.postgre
        .run(query)
        .then((rs) => {
            return res.status(200).json({
                code: 0,
                data: rs.rows,
            })
        })
        .catch((err) => {
            return res.json({
                code: 1,
                err,
            })
        })
})

router.post('/insert-update-tag', (req, res) => {
    const { inputFather, input, type, shain_cd } = req.body
    // Nếu Type là Create
    if (type === 'create') {
        // Kiểm tra Tag Cha đã tồn tại chưa
        const queryCheck = `
            SELECT *
            FROM tbl_tags
            WHERE id_tag = ${inputFather.id_tag}
        `
        db.postgre.run(queryCheck).then((resultCheck) => {
            // Nếu tag cha chưa tồn tại
            if (resultCheck.rows.length === 0) {
                // Kiểm tra Tag Con đã tồn tại chưa
                const queryCheckChild = `
                    SELECT *
                    FROM tbl_tags
                    WHERE id_tag = ${input.id_tag}
                `
                db.postgre.run(queryCheckChild).then((resultCheckChild) => {
                    // Nếu tag Con đã tồn tại
                    if (resultCheckChild.rows.length !== 0) {
                        const queryInsertFather = `
                            ${
                                inputFather.id_tag !== 0
                                    ? `INSERT INTO public.tbl_tags(id_tag, tag_name, created_by)
                            VALUES (${inputFather.id_tag}, '${inputFather.tag_name}', '${shain_cd}');`
                                    : ` SELECT * FROM tbl_tags`
                            }
                        `
                        // Thì Update id_tag_father cho tag con`
                        const query = `
                            UPDATE tbl_tags
                            SET id_tag_father = ${input.id_tag_father},
                                updated_at = now(),
                                updated_by = '${shain_cd}'
                            WHERE id_tag = ${input.id_tag};
                        `
                        Promise.all([db.postgre.run(queryInsertFather), db.postgre.run(query)])
                            .then((result) => {
                                return res.status(200).json({
                                    code: 0,
                                })
                            })
                            .catch((err) => {
                                return res.status(500).json({
                                    code: 1,
                                })
                            })
                    } else {
                        const queryInsertFather = `
                            ${
                                inputFather.id_tag !== 0
                                    ? `INSERT INTO public.tbl_tags(id_tag, tag_name, created_by)
                            VALUES (${inputFather.id_tag}, '${inputFather.tag_name}', '${shain_cd}');`
                                    : ` SELECT * FROM tbl_tags`
                            }
                        `
                        // Nếu Tag con Chưa tồn tại`
                        const query = `
                            ${
                                input.id_tag !== 0
                                    ? `INSERT INTO public.tbl_tags(id_tag, tag_name, id_tag_father, created_by)
                            VALUES (${input.id_tag}, '${input.tag_name}', ${input.id_tag_father}, '${shain_cd}');`
                                    : ` SELECT * FROM tbl_tags `
                            }
                        `
                        Promise.all([db.postgre.run(queryInsertFather), db.postgre.run(query)])
                            .then((result) => {
                                return res.status(200).json({
                                    code: 0,
                                })
                            })
                            .catch((err) => {
                                return res.status(500).json({
                                    code: 1,
                                })
                            })
                    }
                })
            } else {
                // Nếu tag cha Đã tồn tại
                // Kiểm tra Tag Con đã tồn tại chưa
                const queryCheckChild = `
                    SELECT *
                    FROM tbl_tags
                    WHERE id_tag = ${input.id_tag}
                `
                db.postgre.run(queryCheckChild).then((resultCheckChild) => {
                    // Nếu tag Con đã tồn tại
                    if (resultCheckChild.rows.length !== 0) {
                        // Thì Update id_tag_father cho tag con
                        const query = `
                            UPDATE tbl_tags
                            SET id_tag_father = ${input.id_tag_father},
                                updated_at = now(),
                                updated_by = '${shain_cd}'
                            WHERE id_tag = ${input.id_tag};
                        `
                        db.postgre
                            .run(query)
                            .then((result) => {
                                return res.status(200).json({
                                    code: 0,
                                })
                            })
                            .catch((err) => {
                                return res.status(500).json({
                                    code: 1,
                                })
                            })
                    } else {
                        // Nếu tag con chưa tồn tại
                        // Insert tag con
                        const query = `
                            INSERT INTO public.tbl_tags(id_tag, tag_name, id_tag_father, created_by)
                            VALUES (${input.id_tag}, '${input.tag_name}', ${input.id_tag_father}, '${shain_cd}');
                        `
                        db.postgre
                            .run(query)
                            .then((result) => {
                                return res.status(200).json({
                                    code: 0,
                                })
                            })
                            .catch((err) => {
                                return res.status(500).json({
                                    code: 1,
                                })
                            })
                    }
                })
            }
        })
    } else {
        // Nếu Type là Update
        const query = `
            UPDATE tbl_tags
            SET tag_name = '${input.tag_name}',
                id_tag_father = ${input.id_tag_father},
                updated_at = now(),
                updated_by = '${shain_cd}'
            WHERE id_tag = ${input.id_tag};
        `
        db.postgre
            .run(query)
            .then((result) => {
                return res.status(200).json({
                    code: 0,
                })
            })
            .catch((err) => {
                return res.status(500).json({
                    code: 1,
                })
            })
    }
})

const triggerAfterDeleteTag = (id_tag, res) => {
    const query = `
        SELECT kensyuu_id, tags, tags_father
        FROM tbl_kensyuu_master
        WHERE ${id_tag} = ANY(tags) OR ${id_tag} = ANY(tags_father);
    `
    // Mang cac kensyuu co chua id_tag
    db.postgre.run(query).then((result) => {
        const arr = result.rows.map((e) => {
            return {
                ...e,
                tags: e.tags ? e.tags.filter((e1) => e1 !== id_tag) : e.tags,
                tags_father: e.tags_father ? e.tags_father.filter((e2) => e2 !== id_tag) : e.tags_father,
            }
        })
        let queryUpdate = ` SELECT 1; `
        arr.forEach((element) => {
            queryUpdate += `
                UPDATE tbl_kensyuu_master
                SET tags = ${element.tags ? `'{${element.tags}}'` : `null`},
                    tags_father = ${element.tags_father ? `'{${element.tags_father}}'` : `null`}
                WHERE kensyuu_id = '${element.kensyuu_id}';
            `
        })
        return db.postgre.run(queryUpdate).then(() => {
            // return res.status(200).json({
            //     code: 0,
            // })
        })
    })
}

const triggerAfterDeleteHasChildTag = (id_tag, res) => {
    const queryCheck = `
        SELECT id_tag
        FROM tbl_tags
        WHERE id_tag_father = ${id_tag}
    `
    db.postgre.run(queryCheck).then((result) => {
        if (result.rowCount !== 0) {
            result.rows.forEach((element) => {
                // console.log(element)
                triggerAfterDeleteTag(element.id_tag, res)
            })
        }
    })
}

router.post('/delete-tag', (req, res) => {
    const { id_tag } = req.body
    const query = `
        UPDATE tbl_tags
        SET del_fg = true
        WHERE id_tag = ${id_tag};
    `
    if (!id_tag) {
        return res.status(200).json({
            code: 2,
        })
    }
    if (id_tag) {
        db.postgre
            .run(query)
            .then(() => {
                triggerAfterDeleteTag(id_tag, res)
                triggerAfterDeleteHasChildTag(id_tag, res)
                return res.status(200).json({
                    code: 0,
                })
            })
            .catch(() => {
                return res.status(500).json({
                    code: 1,
                })
            })
    }
})

router.post('/search-tag', (req, res) => {
    const { id_tag } = req.body

    const queryCheck = `
        SELECT * FROM tbl_tags
        WHERE ${id_tag !== '0' ? ` id_tag = ${id_tag} ` : ` TRUE `}
    `
    db.postgre.run(queryCheck).then((result1) => {
        if (result1.rows[0].id_tag_father) {
            const query = `
                SELECT t1.id_tag, t1.tag_name, array_agg(concat(t2.id_tag, '-', t2.tag_name)) arr_child
                FROM tbl_tags t1
                LEFT JOIN tbl_tags t2 ON t1.id_tag = t2.id_tag_father
                WHERE  t1.id_tag_father IS NULL AND t1.del_fg = false AND ${id_tag !== '0' ? ` t2.id_tag = ${id_tag} ` : ` TRUE `}
                GROUP BY t1.id_tag, t1.tag_name
                ORDER BY t1.id_tag;
            `
            db.postgre
                .run(query)
                .then((result2) => {
                    return res.status(200).json({
                        data: result2.rows,
                    })
                })
                .catch((err) => {
                    return res.status(500).json({
                        data: [],
                    })
                })
        } else {
            const query = `
                SELECT t1.id_tag, t1.tag_name, array_agg(concat(t2.id_tag, '-', t2.tag_name)) arr_child
                FROM tbl_tags t1
                LEFT JOIN tbl_tags t2 ON t1.id_tag = t2.id_tag_father AND t2.del_fg = false
                WHERE  t1.id_tag_father IS NULL AND t1.del_fg = false AND ${id_tag !== '0' ? ` t1.id_tag = ${id_tag} ` : ` TRUE `}
                GROUP BY t1.id_tag, t1.tag_name
                ORDER BY t1.id_tag;
            `
            db.postgre
                .run(query)
                .then((result2) => {
                    return res.status(200).json({
                        data: result2.rows,
                    })
                })
                .catch((err) => {
                    return res.status(500).json({
                        data: [],
                    })
                })
        }
    })
})

module.exports = router
