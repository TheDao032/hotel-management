const db = require('./models/db')
const mailService = require('./services/mailService')
const queryService = require('./services/queryService')
const constant = require('./common/constant')
/*
 *Thực hiện việc gởi mail tự động với các khóa sắp đến ngày bắt đầu và có status  = 3
 */
let queryTotal = ''
let resultTotal = ''
const query = `
    SELECT * FROM tbl_moushikomi o
    LEFT JOIN view_kensyuu v
            ON o.kensyuu_id = v.kensyuu_id AND o.kensyuu_sub_id = v.kensyuu_sub_id
    WHERE
        status = 3 AND
        moushikomi_id IN (
        SELECT m.moushikomi_id
        FROM v_last_moushikomi m
        LEFT JOIN tbl_kensyuu_nittei_master k
            ON m.kensyuu_id = k.kensyuu_id AND m.kensyuu_sub_id = k.kensyuu_sub_id
        WHERE k.nittei_from = current_date
    )
`
queryTotal += query
db.postgre.run(query).then((result2) => {
    const allData = result2.rows
    resultTotal += JSON.stringify(allData)
    const shain_list = allData.map((item) => `'${item.shain_cd}'`).join(',')
    const sql4 = `
        SELECT *
        FROM (${queryService.shainInfo()}) SHAIN_LIST
        WHERE
            SHAIN_CD IN (${shain_list})
        `
    queryTotal += sql4
    const sql5 = `
        --- SELECT * FROM tbl_mailcontent
        --- ORDER BY id_mail DESC
        --- LIMIT 1
        SELECT  *
	    FROM public.tbl_mail_template WHERE template_id = 'moushikomi_shain';
    `
    queryTotal += sql5
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
                resultTotal += JSON.stringify(newKensyuu)
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
                resultTotal += JSON.stringify(newMoushikomi)
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
                        resultTotal
                    )
                )
            }
            return Promise.all(tasks)
        })
        .catch((err) => {})
})
