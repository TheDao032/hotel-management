const db = require('./models/db')
const mailService = require('./services/mailService')
const queryService = require('./services/queryService')
const constant = require('./common/constant')
/*
 * Gởi mail auto cho học viên khi đến ngày được setup trước
 * Lấy ngày setup ở cột saving_day_send_mail ở bảng tbl_setting của postgre
 */
const sql1 = `
    SELECT saving_day_send_mail
    FROM public.tbl_setting;
`

let queryTotal = ''
let resultQuery = ''
queryTotal += sql1
db.postgre
    .run(sql1)
    .then((result1) => {
        const { saving_day_send_mail } = result1.rows[0]

        if (saving_day_send_mail === 1) return

        const sql2 = `
            SELECT *
            FROM view_kensyuu vk
            RIGHT JOIN v_last_moushikomi tm ON vk.kensyuu_id = tm.kensyuu_id AND vk.kensyuu_sub_id = tm.kensyuu_sub_id
            WHERE vk.kensyuu_id is not null and vk.kensyuu_sub_id is not null
                AND (current_date + 1 = nittei_from)
                AND tm.status IN (3)
        `
        queryTotal += sql2
        db.postgre.run(sql2).then((result2) => {
            const allData = result2.rows
            const shain_list = allData.map((item) => `'${item.shain_cd}'`).join(',')
            const sql4 = `
                SELECT *
                FROM (${queryService.shainInfo()}) SHAIN_LIST
                WHERE
                SHAIN_CD IN (${shain_list})
            `
            queryTotal += sql4
            const sql5 = `
                SELECT *
                FROM tbl_mail_template
                WHERE template_id LIKE 'early%'
            `
            queryTotal += sql5
            const toDO = [db.oracle.run(sql4), db.postgre.run(sql5)]
            return Promise.all(toDO)
                .then(([result4, result5]) => {
                    const data1 = result4.rows
                    const templateData = result5.rows
                    const shainMailTemplate = templateData.filter((e) => e.template_id.includes('kyouiku'))[0]
                    const tasks = []
                    for (let i = 0; i < allData.length; i += 1) {
                        const newKensyuu = {
                            ...allData[i],
                            jyukouryou: (!Number.isNaN(Number(allData[i].jyukouryou)) && `${Number(allData[i].jyukouryou).toLocaleString('en-US')}`) || '',
                        }
                        resultQuery += JSON.stringify(newKensyuu)
                        const data2 = data1.find((e) => e.shain_cd === allData[i].shain_cd)
                        const newMoushikomi = {
                            ...allData[i],
                            mail_address: data2.mail_address,
                            shain_mei: data2.shain_mei,
                            shain_cd: data2.shain_cd,
                            honbu_nm: data2.honbu_nm,
                            bumon_nm: data2.bumon_nm,
                            group_nm: data2.group_nm,
                        }
                        resultQuery += JSON.stringify(newMoushikomi)
                        const shainMailModel = constant.convertToMailModel(shainMailTemplate, newMoushikomi, newKensyuu, data2.mail_address)
                        let shainMailHTML = constant.htmlMail
                        Object.keys(shainMailModel).forEach((key) => {
                            shainMailHTML = shainMailHTML.replace(`${key}`, shainMailModel[key])
                        })

                        tasks.push(
                            mailService.send(
                                {
                                    from: shainMailModel.template_from,
                                    to: data2.mail_address,
                                    cc: shainMailModel.template_cc,
                                    subject: shainMailModel.template_subject,
                                    html: shainMailHTML,
                                },
                                queryTotal,
                                resultQuery
                            )
                        )
                    }
                    return Promise.all(tasks)
                })
                .catch((err) => {})
        })
    })
    .catch((err) => {})
