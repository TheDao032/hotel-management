const router = require('express')()
const fs = require('fs')
    // database
const path = require('path')
const db = require('../models/db')
const notificationService = require('./../services/notificationService')
const authenticationService = require('../services/authenticationService')
const queryService = require('../services/queryService')
const { message, status } = require('./../common')
const mailService = require('../services/mailService')
const constant = require('../common/constant')
const WorkBook = require('../services/excelService').Workbook

router.post('/regist', (req, res) => {
    const { nittei_id } = req.body
    const shain_cd = req.body.shain_cd || req.user.shain_cd
    const boss_cd = req.user.shain_cd
    let resultQuery = ''
    let queryTotal = ''
    const info_query = `
        SELECT *, tbl_kyouiku_shukankikan.mail_shukankikan
        FROM view_kensyuu
        LEFT JOIN tbl_kyouiku_shukankikan
        ON tbl_kyouiku_shukankikan.name_shukankikan = view_kensyuu.shukankikan
        WHERE nittei_id = ${nittei_id}
    `
    queryTotal += info_query
    db.postgre
        .run(info_query)
        .then((kensyuu_info) => {
            if (kensyuu_info.rows.length === 0) throw new Error('can not find kensyuu')
            const { kensyuu_id, kensyuu_sub_id } = kensyuu_info.rows[0]
            const thirdCharOfKensyuuId = kensyuu_id.charAt(2)
            const query = constant.thirdCharKensyuuList.includes(thirdCharOfKensyuuId) ?
                `
                    INSERT INTO tbl_moushikomi
                    (kensyuu_id, kensyuu_sub_id, shain_cd, koushinsha, status)
                    VALUES ('${kensyuu_id}', '${kensyuu_sub_id}', '${shain_cd}', '${boss_cd}', 3)
                    RETURNING moushikomi_id, moushikomi_date::date::text
                ` :
                `
                    INSERT INTO tbl_moushikomi
                    (kensyuu_id, kensyuu_sub_id, shain_cd, koushinsha)
                    VALUES ('${kensyuu_id}', '${kensyuu_sub_id}', '${shain_cd}', '${boss_cd}')
                    RETURNING moushikomi_id, moushikomi_date::date::text
                `
                // const query2 = `
                //   SELECT COUNT(moushikomi_id)
                //   FROM tbl_moushikomi tm
                //   LEFT JOIN tbl_kensyuu_nittei_master knm ON tm.kensyuu_id = knm.kensyuu_id AND tm.kensyuu_sub_id = knm.kensyuu_sub_id
                //   WHERE knm.nittei_id = ${nittei_id}
                //   AND  tm.status IN ('6')
                // `
                // const query3 = `
                //   SELECT mail_subject, mail_content
                //   FROM tbl_mailcontent
                //   WHERE  UPDATE_DATE IN (
                //       SELECT MAX(UPDATE_DATE)
                //       FROM TBL_MAILCONTENT
                //       WHERE MAIL_TYPE = 2
                //   )
                // `
            queryTotal += query
            const tasks = [
                kensyuu_info.rows[0],
                // db.postgre.run(query).then((rs) => rs.rows[0]),
                db.postgre.run(query).then((rs) => rs.rows[0]),
                // db.postgre.run(query2).then((rs) => rs.rows[0]),
                authenticationService.getShainInfo(shain_cd),
                authenticationService.getShainInfo(boss_cd),
            ]

            return Promise.all(tasks)
        })
        // sau khi xong roi thi ghi message lai, gui mail luon
        .then(([kensyuu, moushikomi, shain, boss]) => {
            // const countS = countStudent.count
            // const { mail_content } = mail

            // const shouldSendMail = !kensyuu.nittei_from || Date.now() < new Date(kensyuu.nittei_from).getTime()
            // if (!shouldSendMail) {
            //     return res.status(200).json({
            //         code: 3,
            //     })
            // }
            const tasks = []
            const sql2 = `
                SELECT *
                FROM tbl_mail_template
                WHERE template_id LIKE 'moushikomi_%'
            `
            queryTotal += sql2
            const newKensyuu = {
                ...kensyuu,
                jyukouryou: (!Number.isNaN(Number(kensyuu.jyukouryou)) && `${Number(kensyuu.jyukouryou).toLocaleString('en-US')}`) || '',
            }
            resultQuery += JSON.stringify(newKensyuu)
            const newMoushikomi = {
                ...moushikomi,
                mail_address: shain.mail_address,
                shain_mei: shain.shain_mei,
                shain_cd: shain.shain_cd,
                honbu_nm: shain.honbu_nm,
                bumon_nm: shain.bumon_nm,
                group_nm: shain.group_nm,
            }
            resultQuery += JSON.stringify(newMoushikomi)
            return db.postgre.run(sql2).then((result2) => {
                resultQuery += JSON.stringify(result2)
                const allMoushikomiMailTemplate = result2.rows
                const teacherMailTemplate = allMoushikomiMailTemplate.filter((e) => e.template_id.includes('kyouiku'))[0]
                const shainMailTemplate = allMoushikomiMailTemplate.filter((e) => e.template_id.includes('shain'))[0]
                const bossMailTemplate = allMoushikomiMailTemplate.filter((e) => e.template_id.includes('boss'))[0]
                const teacherMailModel = constant.convertToMailModel(teacherMailTemplate, newMoushikomi, newKensyuu, newKensyuu.mail_shukankikan)
                const shainMailModel = constant.convertToMailModel(shainMailTemplate, newMoushikomi, newKensyuu, shain.mail_address)
                const bossMailModel = constant.convertToMailModel(bossMailTemplate, newMoushikomi, newKensyuu, boss.mail_address)
                let teacherMailHTML = constant.htmlMail
                let shainMailHTML = constant.htmlMail
                let bossMailHTML = constant.htmlMail
                Object.keys(teacherMailModel).forEach((key) => {
                    teacherMailHTML = teacherMailHTML.replace(`${key}`, teacherMailModel[key])
                })
                Object.keys(shainMailModel).forEach((key) => {
                    shainMailHTML = shainMailHTML.replace(`${key}`, shainMailModel[key])
                })
                Object.keys(bossMailModel).forEach((key) => {
                        bossMailHTML = bossMailHTML.replace(`${key}`, bossMailModel[key])
                    })
                    // Truong hop lop da du nguoi
                    // if (countS >= kensyuu.nissuu) {
                    // tasks.push(mailService.send({
                    //     from: '"Kensyuu" <kensyuu@csv.com>', // sender address
                    //     to: shain.mail_address, // list of receivers
                    //     subject: 'Full', // Subject line
                    //     text: '', // plain text body
                    //     html: `
                    //         <p>Full</p>
                    //         ${mail.mail_content}
                    //     `
                    // }))
                    // return res.status(200).json({
                    //     code: 3
                    // })
                    // } else {

                // Get mail template
                // const sql2 = `
                //     SELECT *
                //     FROM tbl_mail_template
                //     WHERE template_id LIKE 'moushikomi_%'
                // `
                // db.postgre.run(sql2).then((result2) => {
                //     const allMailTemplate = result2.rows
                //
                // })

                // Truong hop tu dang ky

                if (shain_cd === boss_cd) {
                    tasks.push(
                        notificationService.insertMessage({
                            shain_cd,
                            moushikomi_id: moushikomi.moushikomi_id,
                            tsuuchi_naiyou: message.W003({
                                kensyuu_mei: kensyuu.kensyuu_mei,
                            }),
                        })
                    )

                    tasks.push(
                        mailService.send({
                                from: shainMailModel.template_from,
                                to: shainMailModel.template_to,
                                cc: shainMailModel.template_cc,
                                subject: shainMailModel.template_subject,
                                html: shainMailHTML,
                            },
                            queryTotal,
                            resultQuery
                        )
                    )

                    tasks.push(
                        mailService.send({
                                from: teacherMailModel.template_from,
                                to: teacherMailModel.template_to,
                                cc: teacherMailModel.template_cc,
                                subject: teacherMailModel.template_subject,
                                html: teacherMailHTML,
                            },
                            queryTotal,
                            resultQuery
                        )
                    )
                } else {
                    const boss_name = boss.shain_mei
                    const shain_name = shain.shain_mei

                    const shainMessage = {
                        moushikomi_id: moushikomi.moushikomi_id,
                        shain_cd,
                        tsuuchi_naiyou: message.W007({
                            boss_name,
                            kensyuu_mei: kensyuu.kensyuu_mei,
                        }),
                    }

                    const adminMessage = {
                        moushikomi_id: moushikomi.moushikomi_id,
                        shain_cd: boss_cd,
                        tsuuchi_naiyou: message.W006({
                            kensyuu_mei: kensyuu.kensyuu_mei,
                            shain_name,
                        }),
                    }

                    tasks.push(notificationService.insertMessage(shainMessage))

                    tasks.push(notificationService.insertMessage(adminMessage))

                    tasks.push(
                        mailService.send({
                                from: shainMailModel.template_from,
                                to: shainMailModel.template_to,
                                cc: shainMailModel.template_cc,
                                subject: shainMailModel.template_subject,
                                html: shainMailHTML,
                            },
                            queryTotal,
                            resultQuery
                        )
                    )

                    tasks.push(
                        mailService.send({
                                from: teacherMailModel.template_from,
                                to: teacherMailModel.template_to,
                                cc: teacherMailModel.template_cc,
                                subject: teacherMailModel.template_subject,
                                html: teacherMailHTML,
                            },
                            queryTotal,
                            resultQuery
                        )
                    )

                    tasks.push(
                        mailService.send({
                                from: bossMailModel.template_from,
                                to: bossMailModel.template_to,
                                cc: bossMailModel.template_cc,
                                subject: bossMailModel.template_subject,
                                html: bossMailHTML,
                            },
                            queryTotal,
                            resultQuery
                        )
                    )
                }
                return Promise.all(tasks)
                    .then(() => {
                        return res.status(200).json({
                            code: 0,
                        })
                    })
                    .catch((error) => {
                        return res.status(200).json({
                            code: 2,
                            error,
                        })
                    })
            })
        })
        .catch((err) => {
            return res.status(500).json({
                err,
                code: 1,
            })
        })
})

router.post('/cancel', (req, res) => {
    const { moushikomi_id } = req.body
    const shain_cd = req.body.shain_cd || req.user.shain_cd
    const boss_cd = req.user.shain_cd
    let resultQuery = ''
    let queryTotal = ''
    const query = `
        UPDATE tbl_moushikomi
        SET status = 8, koushinsha = '${boss_cd}'
        WHERE moushikomi_id = ${moushikomi_id}
        RETURNING moushikomi_id, koushinbi::date::text;
    `
    queryTotal += query
    const info_query = `
        SELECT
        k.*,x.mail_shukankikan
        FROM tbl_moushikomi m
        LEFT JOIN view_kensyuu k ON k.kensyuu_id = m.kensyuu_id AND k.kensyuu_sub_id = m.kensyuu_sub_id
        LEFT JOIN public.tbl_kyouiku_shukankikan x ON x.name_shukankikan = k.shukankikan
        WHERE m.moushikomi_id = ${moushikomi_id}
    `
    queryTotal += info_query
    const tasks = [db.postgre.run(query).then((res1) => res1.rows[0]), db.postgre.run(info_query).then((res2) => res2.rows[0]), authenticationService.getShainInfo(shain_cd)]
    if (shain_cd !== boss_cd) tasks.push(authenticationService.getShainInfo(boss_cd))

    Promise.all(tasks)
        .then(([moushikomi, kensyuu, shain, boss]) => {
            // const countS = countStudent.count
            // const { mail_content } = mail
            const tasks1 = []
            const sql2 = `
                SELECT *
                FROM tbl_mail_template
                WHERE template_id LIKE 'cancel_%'
            `
            queryTotal += sql2
            const newKensyuu = {
                ...kensyuu,
                jyukouryou: (!Number.isNaN(Number(kensyuu.jyukouryou)) && `${Number(kensyuu.jyukouryou).toLocaleString('en-US')}`) || '',
            }
            resultQuery += JSON.stringify(newKensyuu)
            const newMoushikomi = {
                ...moushikomi,
                mail_address: shain.mail_address,
                shain_mei: shain.shain_mei,
                shain_cd: shain.shain_cd,
                honbu_nm: shain.honbu_nm,
                bumon_nm: shain.bumon_nm,
                group_nm: shain.group_nm,
                moushikomi_date: moushikomi.koushinbi,
            }
            resultQuery += JSON.stringify(newMoushikomi)

            db.postgre.run(sql2).then((result2) => {
                const allMoushikomiMailTemplate = result2.rows
                const teacherMailTemplate = allMoushikomiMailTemplate.filter((e) => e.template_id.includes('kyouiku'))[0]
                const shainMailTemplate = allMoushikomiMailTemplate.filter((e) => e.template_id.includes('shain'))[0]
                const bossMailTemplate = allMoushikomiMailTemplate.filter((e) => e.template_id.includes('boss'))[0]
                const teacherMailModel = constant.convertToMailModel(teacherMailTemplate, newMoushikomi, newKensyuu, newKensyuu.mail_shukankikan)
                const shainMailModel = constant.convertToMailModel(shainMailTemplate, newMoushikomi, newKensyuu, shain.mail_address)
                const bossMailModel = constant.convertToMailModel(bossMailTemplate, newMoushikomi, newKensyuu, (boss && boss.mail_address) || '')
                let teacherMailHTML = constant.htmlMail
                let shainMailHTML = constant.htmlMail
                let bossMailHTML = constant.htmlMail
                Object.keys(teacherMailModel).forEach((key) => {
                    teacherMailHTML = teacherMailHTML.replace(`${key}`, teacherMailModel[key])
                })
                Object.keys(shainMailModel).forEach((key) => {
                    shainMailHTML = shainMailHTML.replace(`${key}`, shainMailModel[key])
                })
                Object.keys(bossMailModel).forEach((key) => {
                    bossMailHTML = bossMailHTML.replace(`${key}`, bossMailModel[key])
                })

                tasks1.push(
                    mailService.send({
                            from: teacherMailModel.template_from,
                            to: teacherMailModel.template_to,
                            cc: teacherMailModel.template_cc,
                            subject: teacherMailModel.template_subject,
                            html: teacherMailHTML,
                        },
                        queryTotal,
                        resultQuery
                    )
                )
                if (shain_cd === boss_cd) {
                    const shainMessage = {
                        shain_cd,
                        moushikomi_id,
                        tsuuchi_naiyou: message.W021({
                            kensyuu_mei: kensyuu.kensyuu_mei,
                        }),
                    }
                    tasks1.push(notificationService.insertMessage(shainMessage))
                    tasks1.push(
                        mailService.send({
                                from: shainMailModel.template_from,
                                to: shainMailModel.template_to,
                                cc: shainMailModel.template_cc,
                                subject: shainMailModel.template_subject,
                                html: shainMailHTML,
                            },
                            queryTotal,
                            resultQuery
                        )
                    )
                } else {
                    const bossMessage = {
                        shain_cd: boss_cd,
                        moushikomi_id,
                        tsuuchi_naiyou: message.W008({
                            shain_name: shain.shain_name,
                            kensyuu_mei: kensyuu.kensyuu_mei,
                        }),
                    }
                    const shainMessage = {
                        shain_cd,
                        moushikomi_id,
                        tsuuchi_naiyou: message.W009({
                            boss_name: boss.boss_shain,
                            kensyuu_mei: kensyuu.kensyuu_mei,
                        }),
                    }
                    tasks1.push(notificationService.insertMessage(bossMessage))
                    tasks1.push(notificationService.insertMessage(shainMessage))

                    tasks1.push(
                        mailService.send({
                                from: shainMailModel.template_from,
                                to: shainMailModel.template_to,
                                cc: shainMailModel.template_cc,
                                subject: shainMailModel.template_subject,
                                html: shainMailHTML,
                            },
                            queryTotal,
                            resultQuery
                        )
                    )

                    tasks1.push(
                        mailService.send({
                                from: bossMailModel.template_from,
                                to: bossMailModel.template_to,
                                cc: bossMailModel.template_cc,
                                subject: bossMailModel.template_subject,
                                html: bossMailHTML,
                            },
                            queryTotal,
                            resultQuery
                        )
                    )
                }
                return Promise.all(tasks1)
                    .then(() => {
                        return res.status(200).json({
                            code: 0,
                            success: true,
                        })
                    })
                    .catch((error) => {
                        return res.status(200).json({
                            code: 2,
                            error,
                        })
                    })
            })
        })
        // .then(
        //     () =>
        //         res.status(200).json({
        //             success: true,
        //         }),
        //     (error) => {
        //         return res.status(200).json({
        //             code: 2,
        //             error,
        //         })
        //     }
        // )
        .catch((err) => {
            res.status(500).json({
                code: 1,
                success: false,
                err,
            })
        })
})

router.post('/get-registered-list', (req, res) => {
            const { ki, honbu_cd, bumon_cd, group_cd, kensyuu_mei, shain_cd, shain_mei, kensyuubi_from, kensyuubi_to, shukankikan, tema_category } = req.body
            const paramStatus = req.body.status
                // query filter all kensyuu list registered by condition
            const tbl_moushikomi = `
        SELECT vm.*
        FROM v_last_moushikomi vm
        WHERE ${(ki !== '000' && `kensyuu2ki(vm.kensyuu_id) = '${ki}'`) || ` TRUE `}
        AND vm.status=${paramStatus === '-1' ? 'vm.status' : paramStatus}
    `

    let shukankikanCondittion = ' AND '
    if (shukankikan === '-1' || shukankikan === undefined) {
        shukankikanCondittion += ' TRUE '
    } else if (shukankikan === '' || shukankikan === null) {
        shukankikanCondittion += ` shukankikan = '' OR shukankikan IS NULL `
    } else {
        shukankikanCondittion += ` shukankikan = '${shukankikan}'`
    }

    let temaCondittion = ' AND '
    if (tema_category === '-1' || tema_category === undefined) {
        temaCondittion += ' TRUE '
    } else if (tema_category === '' || tema_category === null) {
        temaCondittion += ` tema_category = '' OR tema_category IS NULL `
    } else {
        temaCondittion += ` tema_category = '${tema_category}'`
    }
    // so sanh -1 hay '-1'
    let statusCondittion = ' AND '
    if (paramStatus === '-1') {
        statusCondittion += ' TRUE '
    } else {
        statusCondittion += ` mo.status = ${paramStatus}`
    }
    const query = `
        SELECT
            mo.moushikomi_id, mo.kensyuu_id, mo.status, mo.shain_cd, mo.koushinsha,
            k.kensyuu_mei, k.tema_category, k.taishosha_level, k.shukankikan, k.jyukouryou,
            k.basho, k.cancel_date, k.moushikomikigen, k.nittei_from
        FROM (${tbl_moushikomi}) mo
        LEFT JOIN view_kensyuu k ON k.kensyuu_id = mo.kensyuu_id AND k.kensyuu_sub_id = mo.kensyuu_sub_id
        WHERE TRUE
            ${(kensyuu_mei &&
                ` AND (lower(k.kensyuu_mei) LIKE '%${kensyuu_mei
                    .trim()
                    .toLowerCase()
                    .replace('_', '\\_')
                    .replace('%', '\\%')}%' ESCAPE '\\' )`) ||
                ''}
                ${shukankikanCondittion}
                ${kensyuubi_from && ` AND '${kensyuubi_from}' <= k.nittei_from `}
                ${kensyuubi_to && ` AND k.nittei_from <= '${kensyuubi_to}' `}
                ${temaCondittion}
                ${statusCondittion}
        ORDER BY mo.status ASC, k.nittei_from ASC
    `
    //
    db.postgre
        .run(query)
        .then((rs) => {
            const data = rs.rows.map((item) => {
                return {
                    ...item,
                    nittei_from: item.nittei_from ? new Date(item.nittei_from) : '',
                    moushikomikigen: item.moushikomikigen ? new Date(item.moushikomikigen) : '',
                    cancel_date: item.cancel_date ? new Date(item.cancel_date) : '',
                }
            })
            //
            if (data.length === 0) return [[], []]
            const filteredDuplicateShainList = []
            new Set(data.map((item) => item.shain_cd)).forEach((value) => filteredDuplicateShainList.push(value))

            const shain_info = `
                SELECT *
                FROM (${queryService.shainInfo(`${ki}`)}) SHAIN_LIST
                WHERE
                ${(!shain_cd && `SHAIN_CD IN (${filteredDuplicateShainList.map((item) => `'${item}'`).join(', ')})`) || `INSTR(SHAIN_CD, '${shain_cd.trim()}') > 0`}
                ${(honbu_cd && `AND HONBU_CD = '${honbu_cd}'`) || ''}
                ${(bumon_cd && `AND BUMON_CD = '${bumon_cd}'`) || ''}
                ${(group_cd && `AND GROUP_CD = '${group_cd}'`) || ''}
                --AND HONBU_CD = NVL('${honbu_cd}', HONBU_CD)
                --AND BUMON_CD = NVL('${bumon_cd}', BUMON_CD)
                --AND GROUP_CD = NVL('${group_cd}', GROUP_CD)
                ${shain_mei &&
                    `
                    AND( (INSTR(lower(SHAIN_MEI), '${shain_mei.trim().toLowerCase()}') > 0)
                    OR (INSTR(lower(SHAIN_MEI_KANA), '${shain_mei.trim().toLowerCase()}') > 0)
                    )
                `}
            `

            return Promise.all([data, db.oracle.run(shain_info)])
        })
        .then(([data, info]) => {
            if (data.length === 0) return data
            const full_data = data
                .map((item) => {
                    const findShain = info.rows.find((row) => row.shain_cd === item.shain_cd) || info.defaultRow
                    return {
                        ...item,
                        shain_mei: findShain.shain_mei,
                        shain_mei_kana: findShain.shain_mei_kana,
                        bumon_nm: findShain.bumon_nm,
                        honbu_nm: findShain.honbu_nm,
                        group_nm: findShain.group_nm,
                        mail_address: findShain.mail_address,
                    }
                })
                .filter((item) => item.shain_mei)
            return full_data
        })
        .then((data) =>
            res.status(200).json({
                data,
            })
        )
        .catch((err) => {
            res.status(500).json({
                data: [],
                err,
            })
        })
})

// new code
router.post('/get-comment', (req, res) => {
    const { nittei_id } = req.body
    const query = `
        SELECT th.hyouka_id AS hyouka_id, th.moushikomi_id AS moushikomi_id,
        th.rating AS rating, th.comment AS comment,
        to_char(th.created_at, 'YYYY/MM/DD HH24:MI:SS') as created_at,
        tm.shain_cd AS shain_cd
        FROM tbl_hyouka th
        LEFT JOIN tbl_moushikomi tm ON th.moushikomi_id = tm.moushikomi_id
        WHERE tm.kensyuu_id = (SELECT kensyuu_id FROM tbl_kensyuu_nittei_master  WHERE nittei_id = ${nittei_id})
    `
    db.postgre
        .run(query)
        .then((rs) => {
            const data = rs.rows.map((item) => {
                return item
            })
            if (data.length === 0) return [[], []]
            const ShainList = []
            new Set(data.map((item) => item.shain_cd)).forEach((value) => ShainList.push(value))
            const shain_info = `
                SELECT SHAIN_LIST.SHAIN_MEI, SHAIN_LIST.SHAIN_CD
                FROM (${queryService.shainInfo()}) SHAIN_LIST
                WHERE
                SHAIN_CD IN (${ShainList.map((item) => `'${item}'`).join(', ')})
            `
            return Promise.all([data, db.oracle.run(shain_info)])
        })
        .then(([data, info]) => {
            if (data.length === 0) return data
            const full_data = data.map((item) => {
                const findShain = info.rows.find((row) => row.shain_cd === item.shain_cd) || info.defaultRow
                return {
                    ...item,
                    shain_mei: findShain.shain_mei,
                }
            })
            return full_data
        })
        .then((data) =>
            res.status(200).json({
                data,
            })
        )
        .catch((err) =>
            res.status(500).json({
                data: [],
                err,
            })
        )
})
// end new code

// rating
router.post('/get-rating', (req, res) => {
    const { nittei_id } = req.body
    const query = `
        SELECT cast(CAST(avg(th.rating) as decimal(3,2)) as float) as avgrating, count(*) countcomment
        ,SUM(CASE WHEN th.rating = 5 THEN 1
            ELSE 0 END) rating5
        ,SUM(CASE WHEN th.rating = 4 THEN 1
            ELSE 0 END) rating4
        ,SUM(CASE WHEN th.rating = 3 THEN 1
            ELSE 0 END) rating3
        ,SUM(CASE WHEN th.rating = 2 THEN 1
            ELSE 0 END) rating2
        ,SUM(CASE WHEN th.rating = 1 THEN 1
            ELSE 0 END) rating1
        ,(count(th.rating) ) calcpercent
        FROM tbl_hyouka th
        LEFT JOIN tbl_moushikomi tm ON th.moushikomi_id = tm.moushikomi_id
        WHERE tm.kensyuu_id = (SELECT kensyuu_id FROM tbl_kensyuu_nittei_master WHERE nittei_id = ${nittei_id})
    `
    db.postgre
        .run(query)
        .then((rs) =>
            res.status(200).json({
                data: rs.rows[0],
            })
        )
        .catch((err) =>
            res.status(500).json({
                data: [],
                err,
            })
        )
})

// end rating
// suggesting
router.post('/get-suggest', (req, res) => {
    //Update By TheDao
    // const { tema_category, taishosha, taishosha_level, kensyuu_category, nittei_id, skill_mg_flag, skill_hm_flag, skill_tc_flag, skill_oa_flag, shukankikan } = req.body
    const { tema_category, taishosha, taishosha_level, kensyuu_category, nittei_id, shukankikan } = req.body
    const query_get_recommend = `
        SELECT *
        FROM public.tbl_recommend_template
        ORDER BY id
    `
    db.postgre
        .run(query_get_recommend)
        .then((result) => {
            const recommend_data = result.rows
            //         const query = `
            //     SELECT tkm.kensyuu_mei
            //     , tkm.skill_mg_flag
            //     , tkm.skill_hm_flag
            //     , tkm.skill_tc_flag
            //     , tkm.skill_oa_flag
            //     , tkm.kensyuu_category
            //     , tkm.tema_category, tkm.kensyuu_gaiyou
            //     , tkm.taishosha
            //     , tkm.kensyuu_id
            //     , tknm.nittei_id
            //     , tknm.nittei_from
            //     , tknm.nittei_to
            //     FROM tbl_kensyuu_nittei_master tknm
            //     LEFT JOIN tbl_kensyuu_master tkm ON tkm.kensyuu_id = tknm.kensyuu_id
            //     WHERE tkm.tema_category = '${tema_category}'
            //     AND tkm.taishosha = '${taishosha}'
            //     AND tkm.kensyuu_category = '${kensyuu_category}'
            //     AND tknm.nittei_id <> ${nittei_id}
            // `
    //         const query = `
    //     SELECT tkm.kensyuu_mei
    //     , tkm.skill_mg_flag
    //     , tkm.skill_hm_flag
    //     , tkm.skill_tc_flag
    //     , tkm.skill_oa_flag
    //     , tkm.kensyuu_category
    //     , tkm.tema_category, tkm.kensyuu_gaiyou
    //     , tkm.taishosha
    //     , tkm.taishosha_level
    //     , tkm.shukankikan
    //     , tkm.kensyuu_id
    //     , tknm.nittei_id
    //     , tknm.nittei_from
    //     , tknm.nittei_to
    //     FROM tbl_kensyuu_nittei_master tknm
    //     LEFT JOIN tbl_kensyuu_master tkm ON tkm.kensyuu_id = tknm.kensyuu_id
    //     WHERE tknm.nittei_id <> ${nittei_id}
    //     AND ${recommend_data[0].is_check === true ? `tkm.kensyuu_category = '${kensyuu_category}'` : ' TRUE '}
    //     AND ${recommend_data[1].is_check === true ? `tkm.shukankikan = '${shukankikan}'` : ' TRUE '}
    //     AND ${recommend_data[2].is_check === true ? `tkm.taishosha = '${taishosha}'` : ' TRUE '}
    //     AND ${recommend_data[3].is_check === true ? `tkm.tema_category = '${tema_category}'` : ' TRUE '}
    //     AND ${recommend_data[4].is_check === true ? `(tkm.skill_mg_flag = '${skill_mg_flag}' OR tkm.skill_hm_flag = '${skill_hm_flag}' OR tkm.skill_tc_flag = '${skill_tc_flag}' OR tkm.skill_oa_flag = '${skill_oa_flag}')` : ' TRUE '}
    //     AND ${recommend_data[5].is_check === true ? `tkm.taishosha_level = '${taishosha_level}'` : ' TRUE '}

    //     AND nittei_from >= current_date
    // `
    const query = `
        SELECT tkm.kensyuu_mei
        , tkm.kensyuu_category
        , tkm.tema_category, tkm.kensyuu_gaiyou
        , tkm.taishosha
        , tkm.taishosha_level
        , tkm.shukankikan
        , tkm.kensyuu_id
        , tknm.nittei_id
        , tknm.nittei_from
        , tknm.nittei_to
        FROM tbl_kensyuu_nittei_master tknm
        LEFT JOIN tbl_kensyuu_master tkm ON tkm.kensyuu_id = tknm.kensyuu_id
        WHERE tknm.nittei_id <> ${nittei_id}
        AND ${recommend_data[0].is_check === true ? `tkm.kensyuu_category = '${kensyuu_category}'` : ' TRUE '}
        AND ${recommend_data[1].is_check === true ? `tkm.shukankikan = '${shukankikan}'` : ' TRUE '}
        AND ${recommend_data[2].is_check === true ? `tkm.taishosha = '${taishosha}'` : ' TRUE '}
        AND ${recommend_data[3].is_check === true ? `tkm.tema_category = '${tema_category}'` : ' TRUE '}
        AND ${recommend_data[4].is_check === true ? `tkm.taishosha_level = '${taishosha_level}'` : ' TRUE '}

        AND nittei_from >= current_date
    `
    //End Update By TheDao
            db.postgre
                .run(query)
                .then((rs) => {
                    const data = rs.rows.map((item) => {
                        return item
                    })

                    return data
                })
                .then((data) => {
                    res.status(200).json(data)
                })
                .catch((err) =>
                    res.status(500).json({
                        data: [],
                        err,
                    })
                )
        })
        .catch((err) =>
            res.status(500).json({
                err,
            })
        )
})

// end suggesting
router.post('/approval-register', (req, res) => {
    const { moushikomi_id } = req.body
    const nitteiStatus = req.body.status
    const boss_cd = req.user.shain_cd
    const nitteiStatusMei = status.getName(nitteiStatus)
    const query = `
        UPDATE tbl_moushikomi
        SET status = ${nitteiStatus},
            koushinsha = '${boss_cd}'
        WHERE moushikomi_id = ${moushikomi_id}
        RETURNING *
    `

    db.postgre
        .run(query)
        .then((result) => {
            if (result.rows.length === 0) {
                throw new Error('khong co gi de update')
            }
            const newMoushikomi = result.rows[0]

            const sql1 = `SELECT * FROM tbl_kensyuu_master WHERE kensyuu_id = '${result.rows[0].kensyuu_id}'`
            return Promise.all([authenticationService.getShainName(boss_cd), authenticationService.getShainName(newMoushikomi.shain_cd), authenticationService.getShainInfo(newMoushikomi.shain_cd), db.postgre.run(sql1)]).then(([boss_name, shain_name, shain, result1]) => {
                const kensyuu = result1.rows[0]
                const adminMessage = {
                    shain_cd: boss_cd,
                    moushikomi_id,
                    tsuuchi_naiyou: message.W004({
                        shain_name,
                        status: nitteiStatusMei,
                    }),
                }
                const shainMessage = {
                    shain_cd: newMoushikomi.shain_cd,
                    moushikomi_id,
                    tsuuchi_naiyou: message.W005({
                        status: nitteiStatusMei,
                        kensyuu_mei: kensyuu.kensyuu_mei,
                        boss_name,
                    }),
                }
                // Start: Send Mail
                const jyukouryou = (!Number.isNaN(kensyuu.jyukouryou) && `? ${Number(kensyuu.jyukouryou).toLocaleString('en-US')}`) || ''
                const newKoushinbi = new Date(newMoushikomi.koushinbi)
                const newKoushinbiText = `${newKoushinbi.getFullYear()}-${newKoushinbi.getMonth() + 1}-${newKoushinbi.getDate()}`
                const tasks = []
                if (nitteiStatus === '3') {
                    tasks.push(
                        mailService.send({
                            from: '"Kensyuu" <kensyuu@csv.com>', // sender address
                            to: shain.mail_address, // list of receivers
                            subject: '【とらんす・ほーむ】承認', // Subject line
                            text: '', // plain text body
                            html: `
                                <p>（本メールは自動配信です。）</p>
                                <p>下記の通り、承認がありました。</p>
                                <p>承認日時：${newKoushinbiText || ''}</p>
                                <p></p>
                                <p>研修ID：${kensyuu.kensyuu_id || ''}</p>
                                <p>研修名：${kensyuu.kensyuu_mei || ''}</p>
                                <p>主管組織：${kensyuu.shukankikan || ''}</p>
                                <p>研修開始日：${kensyuu.nittei_from || ''}</p>
                                <p>研修終了日：${kensyuu.nittei_to || ''}</p>
                                <p>金額：${jyukouryou || ''}</p>
                                <p>研修概要: ${kensyuu.kensyuu_gaiyou || ''}</p>
                                <p>キャンセル期間日: ${kensyuu.cancel_date || ''}</p>
                                <p>キャンセルポリシー： ${kensyuu.cancelpolicy || ''}</p>
                            `,
                        })
                    )
                } else if (nitteiStatus === '10') {
                    tasks.push(
                        mailService.send({
                            from: '"Kensyuu" <kensyuu@csv.com>', // sender address
                            to: shain.mail_address, // list of receivers
                            subject: '【とらんす・ほーむ】不承認', // Subject line
                            text: '', // plain text body
                            html: `
                                <p>（本メールは自動配信です。）</p>
                                <p>下記の通り、不承認がありました。</p>
                                <p>不承認日時：${newKoushinbiText || ''}</p>
                                <p></p>
                                <p>研修ID：${kensyuu.kensyuu_id || ''}</p>
                                <p>研修名：${kensyuu.kensyuu_mei || ''}</p>
                                <p>主管組織：${kensyuu.shukankikan || ''}</p>
                                <p>研修開始日：${kensyuu.nittei_from || ''}</p>
                                <p>研修終了日：${kensyuu.nittei_to || ''}</p>
                                <p>金額：${jyukouryou || ''}</p>
                                <p>研修概要: ${kensyuu.kensyuu_gaiyou || ''}</p>
                                <p>キャンセル期間日: ${kensyuu.cancel_date || ''}</p>
                                <p>キャンセルポリシー： ${kensyuu.cancelpolicy || ''}</p>
                            `,
                        })
                    )
                }
                // End: Send Mail
                return Promise.all([notificationService.insertMessage(adminMessage), notificationService.insertMessage(shainMessage)], tasks).then(() =>
                    res.status(200).json({
                        code: 0,
                        // isNeedToReloadClient,
                        // data: result.rows[0]
                    })
                )
            })
        })
        .catch(() => {
            return res.status(500).json({
                code: 1,
            })
        })
})

router.post('/download-left', (req, res) => {
    const template = path.join(__dirname, '../templates/exports/moushikomi_detail.xlsx')
    const now = Date.now()
    const fileOut = path.join(__dirname, `../tmp/${now}.xlsx`)
    const data = req.body.params.data.map((e) => {
        const nitteiFromDate = new Date(e.nittei_from)
        return {
            ...e,
            nittei_from: `${nitteiFromDate.getMonth() + 1}/${nitteiFromDate.getDate()}/${nitteiFromDate.getFullYear()}`,
        }
    })
    const workBook = new WorkBook()
    try {
        return workBook.xlsx.readFile(template).then(() => {
            const activeSheet = workBook.getWorksheet(0)
            const colAStyle = activeSheet.getCell(`A3`).style
            const colBStyle = activeSheet.getCell(`B3`).style
            const colCStyle = activeSheet.getCell(`C3`).style
            const colDStyle = activeSheet.getCell(`D3`).style
            const colEStyle = activeSheet.getCell(`E3`).style
            const colFStyle = activeSheet.getCell(`F3`).style
            const colGStyle = activeSheet.getCell(`G3`).style
            const colHStyle = activeSheet.getCell(`H3`).style
            const colIStyle = activeSheet.getCell(`I3`).style
            const colJStyle = activeSheet.getCell(`J3`).style
            const colKStyle = activeSheet.getCell(`K3`).style
            const colLStyle = activeSheet.getCell(`L3`).style
            const colMStyle = activeSheet.getCell(`M3`).style
            const colNStyle = activeSheet.getCell(`N3`).style
            const colOStyle = activeSheet.getCell(`O3`).style
            const colPStyle = activeSheet.getCell(`P3`).style
            const colQStyle = activeSheet.getCell(`Q3`).style
            const colRStyle = activeSheet.getCell(`R3`).style
            const colSStyle = activeSheet.getCell(`S3`).style
            const colTStyle = activeSheet.getCell(`T3`).style
            const colUStyle = activeSheet.getCell(`U3`).style

            const colKValue = activeSheet.getCell('K3').value
            const colMValue = activeSheet.getCell('M3').value
            const colNValue = activeSheet.getCell('N3').value

            const colKValidation = {
                type: 'list',
                allowBlank: false,
                formulae: ['"■顧客マスタ指定,■個別指定"'],
            }
            const colNValidation = {
                type: 'list',
                allowBlank: false,
                formulae: ['"☐,■"'],
            }

            const colLeftSumValue = activeSheet.getCell('K4').value
            const colLeftSumStyle = activeSheet.getCell('K4').style
            const colSumStyle = activeSheet.getCell('L4').style
            const colRightSumValue = activeSheet.getCell('M4').value
            const colRightSumStyle = activeSheet.getCell('M4').style

            activeSheet.getCell('K4').value = ''
            activeSheet.getCell('K4').style = ''
            activeSheet.getCell('L4').value = ''
            activeSheet.getCell('L4').style = ''
            activeSheet.getCell('N4').value = ''
            activeSheet.getCell('N4').style = ''
            const startRow = 3
            let index = 0

            data.forEach((item) => {
                const row = startRow + index
                activeSheet.getCell(`A${row}`).value = index + 1
                activeSheet.getCell(`B${row}`).value = ''
                activeSheet.getCell(`C${row}`).value = ''
                activeSheet.getCell(`D${row}`).value = item.kensyuu_mei
                activeSheet.getCell(`E${row}`).value = item.basho
                activeSheet.getCell(`F${row}`).value = item.nittei_from
                activeSheet.getCell(`G${row}`).value = item.shain_mei
                activeSheet.getCell(`H${row}`).value = item.shain_mei_kana
                activeSheet.getCell(`I${row}`).value = item.mail_address
                activeSheet.getCell(`J${row}`).value = `CUBE-${item.shain_cd}`
                activeSheet.getCell(`K${row}`).value = colKValue
                activeSheet.getCell(`L${row}`).value = Number(item.jyukouryou)
                activeSheet.getCell(`M${row}`).value = colMValue
                activeSheet.getCell(`N${row}`).value = colNValue
                activeSheet.getCell(`O${row}`).value = colNValue
                activeSheet.getCell(`P${row}`).value = ''
                activeSheet.getCell(`Q${row}`).value = colNValue
                activeSheet.getCell(`R${row}`).value = ''
                activeSheet.getCell(`S${row}`).value = ''
                activeSheet.getCell(`T${row}`).value = ''
                activeSheet.getCell(`U${row}`).value = ''

                activeSheet.getCell(`A${row}`).style = colAStyle
                activeSheet.getCell(`B${row}`).style = colBStyle
                activeSheet.getCell(`C${row}`).style = colCStyle
                activeSheet.getCell(`D${row}`).style = colDStyle
                activeSheet.getCell(`E${row}`).style = colEStyle
                activeSheet.getCell(`F${row}`).style = colFStyle
                activeSheet.getCell(`G${row}`).style = colGStyle
                activeSheet.getCell(`H${row}`).style = colHStyle
                activeSheet.getCell(`I${row}`).style = colIStyle
                activeSheet.getCell(`J${row}`).style = colJStyle
                activeSheet.getCell(`K${row}`).style = colKStyle
                activeSheet.getCell(`L${row}`).style = colLStyle
                activeSheet.getCell(`M${row}`).style = colMStyle
                activeSheet.getCell(`N${row}`).style = colNStyle
                activeSheet.getCell(`O${row}`).style = colOStyle
                activeSheet.getCell(`P${row}`).style = colPStyle
                activeSheet.getCell(`Q${row}`).style = colQStyle
                activeSheet.getCell(`R${row}`).style = colRStyle
                activeSheet.getCell(`S${row}`).style = colSStyle
                activeSheet.getCell(`T${row}`).style = colTStyle
                activeSheet.getCell(`U${row}`).style = colUStyle

                activeSheet.getCell(`K${row}`).dataValidation = colKValidation
                activeSheet.getCell(`N${row}`).dataValidation = colNValidation
                activeSheet.getCell(`O${row}`).dataValidation = colNValidation
                activeSheet.getCell(`Q${row}`).dataValidation = colNValidation
                index += 1
            })
            const sumRowNum = activeSheet.lastRow.number + 1
            activeSheet.getCell(`K${sumRowNum}`).value = colLeftSumValue
            activeSheet.getCell(`K${sumRowNum}`).style = colLeftSumStyle
            activeSheet.getCell(`L${sumRowNum}`).value = {
                formula: `SUM(L3:L${sumRowNum - 1})`,
            }
            activeSheet.getCell(`L${sumRowNum}`).style = colSumStyle
            activeSheet.getCell(`M${sumRowNum}`).value = colRightSumValue
            activeSheet.getCell(`M${sumRowNum}`).style = colRightSumStyle

            return workBook.xlsx.writeFile(fileOut).then(() =>
                res.download(fileOut, (err) => {
                    if (err) throw err
                    fs.unlink(fileOut, (mistake) => {
                        if (mistake) throw mistake
                    })
                })
            )
        })
    } catch (error) {
        return res.status(500).json({
            code: 3,
        })
    }
})

router.post('/download-right', (req, res) => {
    const template = path.join(__dirname, '../templates/exports/moushikomi_detail_kensyuu_mei.xlsx')
    const now = Date.now()
    const fileOut = path.join(__dirname, `../tmp/${now}.xlsx`)
    const data = req.body.params.data.map((e) => {
        const mei = e.kensyuu_mei.trim()
        const first = (mei.indexOf('(') !== -1 && mei.indexOf('(')) || mei.indexOf('(')
        const last = (mei.indexOf(')') !== -1 && mei.indexOf(')')) || mei.indexOf(')')
        const nitteiFromDate = new Date(e.nittei_from)
        return {
            ...e,
            kensyuu_mei: mei.slice(first + 1, last),
            nittei_from: `${nitteiFromDate.getMonth() + 1}/${nitteiFromDate.getDate()}/${nitteiFromDate.getFullYear()}`,
        }
    })
    const workBook = new WorkBook()
    try {
        return workBook.xlsx.readFile(template).then(() => {
            const activeSheet = workBook.getWorksheet('Sheet1')
            const borderRight = activeSheet.getCell('G4').style.border.right
            activeSheet.getCell('G5').style.border.right = borderRight
            activeSheet.getCell('G7').style.border.right = borderRight
            activeSheet.getCell('B17').style.border.bottom = {
                style: 'thin',
            }
            activeSheet.getCell('C17').style.border.bottom = {
                style: 'thin',
            }
            activeSheet.getCell('C18').style.border.bottom = {
                style: 'thin',
            }

            const HEADER_B_VALUE = activeSheet.getCell('B21').value

            const HEADER_C_VALUE = activeSheet.getCell('C21').value
            // const HEADER_D_VALUE = ''
            // const HEADER_E_VALUE = ''
            const HEADER_F_VALUE = activeSheet.getCell('F21').value
            const HEADER_G_VALUE = activeSheet.getCell('G21').value
            // const HEADER_H_VALUE = ''
            // const HEADER_I_VALUE = ''
            const HEADER_J_VALUE = activeSheet.getCell('J21').value

            // const HEADER_B1_VALUE = ''
            // const HEADER_C1_VALUE = ''
            // const HEADER_D1_VALUE = ''
            // const HEADER_E1_VALUE = ''
            // const HEADER_F1_VALUE = ''
            const HEADER_G1_VALUE = activeSheet.getCell('G22').value
            const HEADER_H1_VALUE = activeSheet.getCell('H22').value
            const HEADER_I1_VALUE = activeSheet.getCell('I22').value
            // const HEADER_J1_VALUE = ''

            const IS_STYLE = activeSheet.getCell('B21').style
            const IS_TITLE_VALUE = activeSheet.getCell('B20').value
            const IS_TITLE_STYLE = activeSheet.getCell('B20').style

            const BS_STYLE = activeSheet.getCell('B25').style

            const BS_TITLE_VALUE = activeSheet.getCell('B24').value
            const BS_TITLE_STYLE = activeSheet.getCell('B24').style

            const COLA_STYLE = activeSheet.getCell('A28').style
            const COLB_STYLE = activeSheet.getCell('B28').style
            const COLC_STYLE = activeSheet.getCell('C28').style
            const COLD_STYLE = activeSheet.getCell('D28').style
            const COLE_STYLE = activeSheet.getCell('E28').style
            const COLF_STYLE = activeSheet.getCell('F28').style
            const COLG_STYLE = activeSheet.getCell('G28').style
            const COLH_STYLE = activeSheet.getCell('H28').style
            const COLI_STYLE = activeSheet.getCell('I28').style
            const COLJ_STYLE = activeSheet.getCell('J28').style

            const PM_FORMULAR = (cell) => {
                return `IF(${cell} = "", "", VLOOKUP(${cell}, $L$13: $M$17, 2, 0))`
            }
            const IS_FORMULAR = (cell) => {
                return `IF(${cell} = "", "", VLOOKUP(${cell}, $L$18: $M$20, 2, 0))`
            }
            const BS_FORMULAR = (cell) => {
                return `IF(${cell} = "", "", VLOOKUP(${cell}, $L$21: $M$25, 2, 0))`
            }

            activeSheet.unMergeCells('B20:J28')
            activeSheet.getCell('J22').value = ''
            activeSheet.getCell('J22').style = ''
            activeSheet.getCell('J26').value = ''
            activeSheet.getCell('J26').style = ''

            activeSheet.getCell('B28').value = ''
            activeSheet.getCell('B28').style = ''
            activeSheet.getCell('C28').value = ''
            activeSheet.getCell('C28').style = ''
            activeSheet.getCell('F28').value = ''
            activeSheet.getCell('F28').style = ''
            activeSheet.getCell('G28').value = ''
            activeSheet.getCell('G28').style = ''
            activeSheet.getCell('H28').value = ''
            activeSheet.getCell('H28').style = ''
            activeSheet.getCell('I28').value = ''
            activeSheet.getCell('I28').style = ''
            activeSheet.getCell('J28').value = ''
            activeSheet.getCell('J28').style = ''
            for (let count = 20; count <= 27; count += 1) {
                const eachRow = activeSheet.getRow(count)
                eachRow.eachCell((cell, colNumber) => {
                    if (colNumber <= 11) {
                        // eslint-disable-next-line no-param-reassign
                        cell.value = ''
                        // eslint-disable-next-line no-param-reassign
                        cell.style = ''
                    }
                })
            }

            const dataPM = data.filter((e) => e.kensyuu_mei.includes('PM-'))
            const dataIS = data.filter((e) => e.kensyuu_mei.includes('IS-'))
            const dataBS = data.filter((e) => e.kensyuu_mei.includes('BS-'))
            // PM PART
            let startRow = 19
            let index = 1
            dataPM.forEach((pm) => {
                activeSheet.getCell(`A${startRow}`).value = index
                activeSheet.getCell(`B${startRow}`).value = pm.kensyuu_mei
                activeSheet.getCell(`B${startRow}`).dataValidation = {
                    type: 'list',
                    allowBlank: false,
                    formulae: ['$L$13:$L$17'],
                }
                activeSheet.mergeCells(`C${startRow}:E${startRow}}`)
                activeSheet.getCell(`D${startRow}`).value = ''
                activeSheet.getCell(`E${startRow}`).value = ''
                activeSheet.getCell(`F${startRow}`).value = pm.nittei_from || ' - '
                activeSheet.getCell(`G${startRow}`).value = pm.shain_mei || ' - '
                activeSheet.getCell(`H${startRow}`).value = pm.shain_mei_kana || ' - '
                activeSheet.getCell(`I${startRow}`).value = pm.honbu_nm || ' - '
                activeSheet.getCell(`J${startRow}`).value = ''

                activeSheet.getCell(`A${startRow}`).style = COLA_STYLE
                activeSheet.getCell(`B${startRow}`).style = COLB_STYLE
                activeSheet.getCell(`C${startRow}`).style = COLC_STYLE
                activeSheet.getCell(`D${startRow}`).style = COLD_STYLE
                activeSheet.getCell(`E${startRow}`).style = COLE_STYLE
                activeSheet.getCell(`F${startRow}`).style = COLF_STYLE
                activeSheet.getCell(`G${startRow}`).style = COLG_STYLE
                activeSheet.getCell(`H${startRow}`).style = COLH_STYLE
                activeSheet.getCell(`I${startRow}`).style = COLI_STYLE
                activeSheet.getCell(`J${startRow}`).style = COLJ_STYLE
                activeSheet.getCell(`C${startRow}`).value = {
                    formula: PM_FORMULAR(`B${startRow}`),
                }
                startRow += 1
                index += 1
            })
            // IS PART
            startRow += 1
            activeSheet.getCell(`B${startRow}`).value = IS_TITLE_VALUE
            activeSheet.getCell(`B${startRow}`).style = IS_TITLE_STYLE

            startRow += 1
            activeSheet.mergeCells(`B${startRow}:B${startRow + 1}`)
            activeSheet.mergeCells(`C${startRow}:E${startRow + 1}`)
            activeSheet.mergeCells(`F${startRow}:F${startRow + 1}`)
            activeSheet.mergeCells(`G${startRow}:I${startRow}`)
            activeSheet.mergeCells(`J${startRow}:J${startRow + 1}`)

            activeSheet.getCell(`B${startRow}`).value = HEADER_B_VALUE
            activeSheet.getCell(`C${startRow}`).value = HEADER_C_VALUE
            activeSheet.getCell(`F${startRow}`).value = HEADER_F_VALUE
            activeSheet.getCell(`J${startRow}`).value = HEADER_J_VALUE

            activeSheet.getCell(`B${startRow}`).style = IS_STYLE
            activeSheet.getCell(`C${startRow}`).style = IS_STYLE
            activeSheet.getCell(`D${startRow}`).style = IS_STYLE
            activeSheet.getCell(`E${startRow}`).style = IS_STYLE
            activeSheet.getCell(`F${startRow}`).style = IS_STYLE
            activeSheet.getCell(`G${startRow}`).style = IS_STYLE
            activeSheet.getCell(`H${startRow}`).style = IS_STYLE
            activeSheet.getCell(`I${startRow}`).style = IS_STYLE
            activeSheet.getCell(`J${startRow}`).style = IS_STYLE

            startRow += 1
            activeSheet.getCell(`G${startRow}`).value = HEADER_G1_VALUE
            activeSheet.getCell(`H${startRow}`).value = HEADER_H1_VALUE
            activeSheet.getCell(`I${startRow}`).value = HEADER_I1_VALUE

            activeSheet.getCell(`B${startRow}`).style = IS_STYLE
            activeSheet.getCell(`C${startRow}`).style = IS_STYLE
            activeSheet.getCell(`D${startRow}`).style = IS_STYLE
            activeSheet.getCell(`E${startRow}`).style = IS_STYLE
            activeSheet.getCell(`F${startRow}`).style = IS_STYLE
            activeSheet.getCell(`G${startRow}`).style = IS_STYLE
            activeSheet.getCell(`H${startRow}`).style = IS_STYLE
            activeSheet.getCell(`I${startRow}`).style = IS_STYLE
            activeSheet.getCell(`J${startRow}`).style = IS_STYLE

            startRow += 1

            index = 1

            dataIS.forEach((is) => {
                activeSheet.getCell(`A${startRow}`).value = index
                activeSheet.getCell(`B${startRow}`).value = is.kensyuu_mei
                activeSheet.getCell(`B${startRow}`).dataValidation = {
                    type: 'list',
                    allowBlank: false,
                    formulae: ['$L$18:$L$20'],
                }
                activeSheet.mergeCells(`C${startRow}:E${startRow}}`)
                activeSheet.getCell(`D${startRow}`).value = ''
                activeSheet.getCell(`E${startRow}`).value = ''
                activeSheet.getCell(`F${startRow}`).value = is.nittei_from || ' - '
                activeSheet.getCell(`G${startRow}`).value = is.shain_mei || ' - '
                activeSheet.getCell(`H${startRow}`).value = is.shain_mei_kana || ' - '
                activeSheet.getCell(`I${startRow}`).value = is.honbu_nm || ' - '
                activeSheet.getCell(`J${startRow}`).value = ''

                activeSheet.getCell(`A${startRow}`).style = COLA_STYLE
                activeSheet.getCell(`B${startRow}`).style = COLB_STYLE
                activeSheet.getCell(`C${startRow}`).style = COLC_STYLE
                activeSheet.getCell(`D${startRow}`).style = COLD_STYLE
                activeSheet.getCell(`E${startRow}`).style = COLE_STYLE
                activeSheet.getCell(`F${startRow}`).style = COLF_STYLE
                activeSheet.getCell(`G${startRow}`).style = COLG_STYLE
                activeSheet.getCell(`H${startRow}`).style = COLH_STYLE
                activeSheet.getCell(`I${startRow}`).style = COLI_STYLE
                activeSheet.getCell(`J${startRow}`).style = COLJ_STYLE
                activeSheet.getCell(`C${startRow}`).value = {
                    formula: IS_FORMULAR(`B${startRow}`),
                }
                startRow += 1
                index += 1
            })

            // BS_PART
            startRow += 1
            activeSheet.getCell(`B${startRow}`).value = BS_TITLE_VALUE
            activeSheet.getCell(`B${startRow}`).style = BS_TITLE_STYLE

            startRow += 1
            activeSheet.mergeCells(`B${startRow}:B${startRow + 1}`)
            activeSheet.mergeCells(`C${startRow}:E${startRow + 1}`)
            activeSheet.mergeCells(`F${startRow}:F${startRow + 1}`)
            activeSheet.mergeCells(`G${startRow}:I${startRow}`)
            activeSheet.mergeCells(`J${startRow}:J${startRow + 1}`)

            activeSheet.getCell(`B${startRow}`).value = HEADER_B_VALUE
            activeSheet.getCell(`C${startRow}`).value = HEADER_C_VALUE
            activeSheet.getCell(`G${startRow}`).value = HEADER_G_VALUE
            activeSheet.getCell(`J${startRow}`).value = HEADER_J_VALUE

            activeSheet.getCell(`B${startRow}`).style = BS_STYLE
            activeSheet.getCell(`C${startRow}`).style = BS_STYLE
            activeSheet.getCell(`D${startRow}`).style = BS_STYLE
            activeSheet.getCell(`E${startRow}`).style = BS_STYLE
            activeSheet.getCell(`F${startRow}`).style = BS_STYLE
            activeSheet.getCell(`G${startRow}`).style = BS_STYLE
            activeSheet.getCell(`H${startRow}`).style = BS_STYLE
            activeSheet.getCell(`I${startRow}`).style = BS_STYLE
            activeSheet.getCell(`J${startRow}`).style = BS_STYLE

            activeSheet.getCell(`C${startRow}`).style = BS_STYLE
            activeSheet.getCell(`D${startRow}`).style = BS_STYLE
            activeSheet.getCell(`E${startRow}`).style = BS_STYLE
            activeSheet.getCell(`F${startRow}`).style = BS_STYLE
            activeSheet.getCell(`G${startRow}`).style = BS_STYLE
            activeSheet.getCell(`H${startRow}`).style = BS_STYLE
            activeSheet.getCell(`I${startRow}`).style = BS_STYLE
            activeSheet.getCell(`J${startRow}`).style = BS_STYLE

            startRow += 1
            activeSheet.getCell(`G${startRow}`).value = HEADER_G1_VALUE
            activeSheet.getCell(`H${startRow}`).value = HEADER_H1_VALUE
            activeSheet.getCell(`I${startRow}`).value = HEADER_I1_VALUE

            activeSheet.getCell(`B${startRow}`).style = BS_STYLE
            activeSheet.getCell(`C${startRow}`).style = BS_STYLE
            activeSheet.getCell(`D${startRow}`).style = BS_STYLE
            activeSheet.getCell(`E${startRow}`).style = BS_STYLE
            activeSheet.getCell(`F${startRow}`).style = BS_STYLE
            activeSheet.getCell(`G${startRow}`).style = BS_STYLE
            activeSheet.getCell(`H${startRow}`).style = BS_STYLE
            activeSheet.getCell(`I${startRow}`).style = BS_STYLE
            activeSheet.getCell(`J${startRow}`).style = BS_STYLE

            startRow += 1

            index = 1
            dataBS.forEach((bs) => {
                activeSheet.getCell(`A${startRow}`).value = index
                activeSheet.getCell(`B${startRow}`).value = bs.kensyuu_mei
                activeSheet.getCell(`B${startRow}`).dataValidation = {
                    type: 'list',
                    allowBlank: false,
                    formulae: ['$L$21:$L$25'],
                }
                activeSheet.mergeCells(`C${startRow}:E${startRow}}`)
                activeSheet.getCell(`D${startRow}`).value = ''
                activeSheet.getCell(`E${startRow}`).value = ''
                activeSheet.getCell(`F${startRow}`).value = bs.nittei_from || ' - '
                activeSheet.getCell(`G${startRow}`).value = bs.shain_mei || ' - '
                activeSheet.getCell(`H${startRow}`).value = bs.shain_mei_kana || ' - '
                activeSheet.getCell(`I${startRow}`).value = bs.honbu_nm || ' - '
                activeSheet.getCell(`J${startRow}`).value = ''

                activeSheet.getCell(`A${startRow}`).style = COLA_STYLE
                activeSheet.getCell(`B${startRow}`).style = COLB_STYLE
                activeSheet.getCell(`C${startRow}`).style = COLC_STYLE
                activeSheet.getCell(`D${startRow}`).style = COLD_STYLE
                activeSheet.getCell(`E${startRow}`).style = COLE_STYLE
                activeSheet.getCell(`F${startRow}`).style = COLF_STYLE
                activeSheet.getCell(`G${startRow}`).style = COLG_STYLE
                activeSheet.getCell(`H${startRow}`).style = COLH_STYLE
                activeSheet.getCell(`I${startRow}`).style = COLI_STYLE
                activeSheet.getCell(`J${startRow}`).style = COLJ_STYLE
                activeSheet.getCell(`C${startRow}`).value = {
                    formula: BS_FORMULAR(`B${startRow}`),
                }
                startRow += 1
                index += 1
            })

            activeSheet.pageSetup.printArea = `A1:J${startRow}`
            return workBook.xlsx.writeFile(fileOut).then(() =>
                res.download(fileOut, (err) => {
                    if (err) throw err
                    fs.unlink(fileOut, (mistake) => {
                        if (mistake) throw mistake
                    })
                })
            )
        })
    } catch (error) {
        return res.status(500).json({
            code: 3,
        })
    }
})

router.post('/get-config', (req, res) => {
    const { id } = req.body
    const sql = `
        SELECT *
        FROM tbl_mail_config
        WHERE id = '${id}'
    `
    db.postgre
        .run(sql)
        .then((result) => {
            if (result.rows.length === 0) {
                res.status(200).json({
                    code: 0,
                })
            }
        })
        .catch((err) => {
            res.status(500).json({
                code: 1,
                data: [],
                err,
            })
        })
})
router.post('/send-mail-auto', (req, res) => {
    const { status, moushikomikigen, shain_cd, moushikomi_id } = req.body
    const query = `
        SELECT * FROM tbl_moushikomi o
        LEFT JOIN view_kensyuu v
            ON o.kensyuu_id = v.kensyuu_id AND o.kensyuu_sub_id = v.kensyuu_sub_id
        WHERE
            status = ${status} AND
            moushikomi_id IN (
        SELECT m.moushikomi_id
        FROM v_last_moushikomi m
        LEFT JOIN tbl_kensyuu_nittei_master k
            ON m.kensyuu_id = k.kensyuu_id AND m.kensyuu_sub_id = k.kensyuu_sub_id
        WHERE m.moushikomi_id = '${moushikomi_id}'
            AND v.moushikomikigen = '${moushikomikigen}'
            AND m.shain_cd = '${shain_cd}'
        )
    `
    db.postgre.run(query).then((result2) => {
        const allData = result2.rows
        const sql4 = `
            SELECT *
            FROM m_shain
            WHERE
                shain_cd = '${shain_cd}'
            `
        const sql5 = `
            SELECT  *
            FROM public.tbl_mail_template where template_id = 'moushikomi_shain';
        `
        const toDO = [db.oracle.run(sql4), db.postgre.run(sql5)]
        return Promise.all(toDO)
            .then(([result4, result5]) => {
                const data1 = result4.rows
                const templateData = result5.rows
                const shainMailTemplate = templateData.filter((e) => e.template_id.includes('shain'))[0]
                const tasks = []
                for (let i = 0; i < allData.length; i += 1) {
                    const newKensyuu = {
                        ...allData[i],
                        jyukouryou: (!Number.isNaN(Number(allData[i].jyukouryou)) && `${Number(allData[i].jyukouryou).toLocaleString('en-US')}`) || '',
                    }

                    const data2 = data1.find((e) => e.shain_cd === allData[i].shain_cd)
                    const newMoushikomi = {
                        ...allData[i],
                        mail_address: data2[i].mail_address,
                        shain_mei: data2[i].shain_mei,
                        shain_cd: data2[i].shain_cd,
                        honbu_nm: data2[i].honbu_nm,
                        bumon_nm: data2[i].bumon_nm,
                        group_nm: data2[i].group_nm,
                    }

                    const shainMailModel = constant.convertToMailModel(shainMailTemplate, newMoushikomi, newKensyuu, data2[i].mail_address)

                    let shainMailHTML = constant.htmlMail

                    Object.keys(shainMailModel).forEach((key) => {
                        shainMailHTML = shainMailHTML.replace(`${key}`, shainMailModel[key])
                    })
                    tasks.push(
                        mailService.send({
                            from: shainMailModel.template_from,
                            to: data2[i].mail_address,
                            cc: shainMailModel.template_cc,
                            subject: shainMailModel.template_subject,
                            html: shainMailHTML,
                        })
                    )
                }
                return Promise.all(tasks)
            })
            .catch((err) => {})
    })
})
module.exports = router
