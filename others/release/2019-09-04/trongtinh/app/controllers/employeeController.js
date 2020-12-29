const express = require('express')

const router = express.Router()
const moment = require('moment')
const path = require('path')
const fs = require('fs')
const multer = require('multer')
const dateFormat = require('dateformat')
const queryService = require('../services/queryService')
const { SuperWorkbook } = require('../services/excelService')
const { Workbook } = require('../services/excelService')
const db = require('../models/db')
const common = require('../common')

const upload = multer({
    dest: path.join(__dirname, '../uploads/'),
})

router.post('/attend-list', (req, res) => {
    const { ki, honbu_cd, bumon_cd, group_cd, shain_cd, shain_mei } = req.body
    const shain_list_query = `
        SELECT DISTINCT shain_cd
        FROM tbl_moushikomi
        WHERE kensyuu2ki(kensyuu_id) = '${ki}'
        AND shain_cd <> '#N/A'
        ORDER BY shain_cd
    `
    db.postgre
        .run(shain_list_query)
        .then((result) => {
            if (result.rows.length === 0) {
                return res.status(200).json({
                    code: 0,
                    data: [],
                })
            }
            const shain_list = result.rows.map((item) => `'${item.shain_cd}'`)
            const sqlShainInfo = `
                SELECT
                SHA.SHAIN_CD, SHA.MAIL_ADDRESS,
                (SHA.SHAIN_SEI || ' ' || SHA.SHAIN_NM) AS SHAIN_MEI,
                (SHA.SHAIN_SEI_KANA || ' ' || SHA.SHAIN_NM_KANA) AS SHAIN_MEI_KANA,
                SOSHNB.SOSHIKI_NM AS HONBU_NM,
                SOSHNB.SOSHIKI_CD AS HONBU_CD,
                CASE WHEN SOSHNB.SOSHIKI_CD = SOSGRP.SOSHIKI_CD THEN '-' ELSE SOSBMN.SOSHIKI_NM END AS BUMON_NM,
                CASE WHEN SOSHNB.SOSHIKI_CD = SOSGRP.SOSHIKI_CD THEN '-' ELSE SOSBMN.SOSHIKI_CD END AS BUMON_CD,
                CASE WHEN SOSBMN.SOSHIKI_CD = SOSGRP.SOSHIKI_CD THEN '-' ELSE SOSGRP.SOSHIKI_NM END AS GROUP_NM,
                CASE WHEN SOSBMN.SOSHIKI_CD = SOSGRP.SOSHIKI_CD THEN '-' ELSE SOSGRP.SOSHIKI_CD END AS GROUP_CD,
                YAK.YAKUSHOKU_NM
                FROM M_SHAIN SHA
                LEFT JOIN M_HAIZOKU_YS HAI
                ON HAI.PRIORITY_KBN = '0' AND HAI.SHAIN_CD = SHA.SHAIN_CD
                LEFT JOIN M_SOSHIKI_YS SOSGRP
                ON SOSGRP.KI_KBN = HAI.KI_KBN AND SOSGRP.SOSHIKI_CD = HAI.SOSHIKI_CD
                LEFT JOIN M_SOSHIKI_YS SOSBMN
                ON SOSBMN.KI_KBN = SOSGRP.KI_KBN AND SOSBMN.SOSHIKI_CD = SOSGRP.BUMON_CD
                LEFT JOIN M_SOSHIKI_YS SOSHNB
                ON SOSHNB.KI_KBN = SOSBMN.KI_KBN AND SOSHNB.SOSHIKI_CD = SOSBMN.HONBU_CD
                LEFT JOIN M_YAKUSHOKU YAK
                ON YAK.YAKUSHOKU_CD = HAI.YAKUSHOKU_CD
                WHERE HAI.KI_KBN = '${ki}'
                AND SHA.ZAISHOKU_KBN = '01'
                AND SHA.SHAIN_CD NOT LIKE '9%'
                    -- AND SHA.SHAIN_CD = NVL(:SHAIN_CD, SHA.SHAIN_CD)
                    -- AND SHA.SHAIN_SEI || SHA.SHAIN_NM LIKE NVL(:SHAIN_NM, SHA.SHAIN_SEI || SHA.SHAIN_NM)
                ORDER BY
                SOSHNB.SEQUENCE_NO,
                CASE
                    WHEN SOSHNB.SOSHIKI_CD = SOSGRP.SOSHIKI_CD THEN 0
                    ELSE SOSBMN.SEQUENCE_NO
                END,
                SOSGRP.SEQUENCE_NO,
                SHA.SHAIN_CD
            `
            const shain_info = `
                SELECT DISTINCT *
                FROM (
                    ${sqlShainInfo}
                ) SHAIN_LIST
                WHERE
                    SHAIN_CD IN (${shain_list})
                    AND (SHAIN_CD LIKE NVL('%${shain_cd
                        .trim()
                        .replace('_', '\\_')
                        .replace('%', '\\%')}%', SHAIN_CD) ESCAPE '\\' )
                    AND (
                        INSTR(LOWER(SHAIN_MEI), NVL('${shain_mei.trim().toLocaleLowerCase()}', LOWER(SHAIN_MEI))) < > 0
                        OR INSTR(LOWER(SHAIN_MEI_KANA), NVL('${shain_mei.trim().toLocaleLowerCase()}', LOWER(SHAIN_MEI_KANA))) < > 0
                    )
                    ${(honbu_cd && `AND HONBU_CD = '${honbu_cd}'`) || ''}
                    ${(bumon_cd && `AND BUMON_CD = '${bumon_cd}'`) || ''}
                    ${(group_cd && `AND GROUP_CD = '${group_cd}'`) || ''}
                --AND HONBU_CD = NVL('${honbu_cd}', HONBU_CD)
                --AND BUMON_CD = NVL('${bumon_cd}', BUMON_CD)
                --AND GROUP_CD = NVL('${group_cd}', GROUP_CD)
            `
            return db.oracle.run(shain_info).then((result1) => {
                return res.status(200).json({
                    data: result1.rows,
                })
            })
        })
        .catch((err) => console.log(err))
})

router.post('/download', (req, res) => {
    const toukyou_oosaka_flag = {
        1: '東京',
        2: '大阪',
        3: 'その他',
    }
    // Use 2 SQL query to get shainData + kensyuuData and combine them together.
    let shainData = []
    let kensyuuData = []
    const { ki, honbu_cd, bumon_cd, group_cd, shain_cd, shain_mei } = req.body

    const template = path.join(__dirname, '../templates/exports/jukou_rireki.xlsx')
    const now = new Date().valueOf()
    const filename_out = path.join(__dirname, `../tmp/${now}.xlsx`)
    const workbook = new SuperWorkbook({
        active: '受講履歴 (社員別)',
        style: 'style',
        col: {
            s: 1,
            e: 23,
        },
    })
    const shain_list_query = `
        SELECT DISTINCT shain_cd
        FROM tbl_moushikomi
        WHERE ${(ki !== '000' && `kensyuu2ki(kensyuu_id) = '${ki}'`) || ` TRUE `}
    `
    Promise.all([db.postgre.run(shain_list_query), workbook.xlsx.readFile(template)])
        .then(([result]) => {
            if (result.rows.length === 0) return []
            const shain_list = result.rows.map((item) => `'${item.shain_cd}'`)
            const shainQuery = `
                SELECT *
                FROM (${queryService.shainInfo(ki)}) SHAIN_LIST
                WHERE
                SHAIN_CD IN (${shain_list})
                AND (SHAIN_CD LIKE NVL('%${shain_cd
                    .trim()
                    .replace('_', '\\_')
                    .replace('%', '\\%')}%', SHAIN_CD) ESCAPE '\\' )
                AND (
                    INSTR(LOWER(SHAIN_MEI), NVL('${shain_mei.trim().toLocaleLowerCase()}', LOWER(SHAIN_MEI))) < > 0
                    OR INSTR(LOWER(SHAIN_MEI_KANA), NVL('${shain_mei.trim().toLocaleLowerCase()}', LOWER(SHAIN_MEI_KANA))) < > 0
                )
                ${(honbu_cd && `AND HONBU_CD = '${honbu_cd}'`) || ''}
                ${(bumon_cd && `AND BUMON_CD = '${bumon_cd}'`) || ''}
                ${(group_cd && `AND GROUP_CD = '${group_cd}'`) || ''}
                --AND HONBU_CD = NVL('${honbu_cd}', HONBU_CD)
                --AND BUMON_CD = NVL('${bumon_cd}', BUMON_CD)
                --AND GROUP_CD = NVL('${group_cd}', GROUP_CD)
            `
            // console.log(shainQuery)
            return db.oracle.run(shainQuery)
        })
        .then((shainResult) => {
            if (shainResult.rows.length === 0) throw 'No shain Data'
            const shainCDList = []
            shainResult.rows.forEach((item) => shainCDList.push(`'${item.shain_cd}'`))
            shainData = shainResult.rows
            const kensyuuQuery = `
                SELECT m.kensyuu_id,
                    m.shain_cd,
                    m.status,
                    m.koushinsha,
                    m.koushinbi,
                    m.moushikomi_date,
                    v.kensyuu_mei,
                    v.jyukouryou,
                    v.shukankikan,
                    v.bikou,
                    v.tema_category,
                    v.taishosha_level,
                    v.nittei_from,
                    v.toukyou_oosaka_flag,
                    v.basho
                FROM tbl_moushikomi m
                LEFT JOIN view_kensyuu v
                    ON m.kensyuu_id = v.kensyuu_id
                    AND m.kensyuu_sub_id = v.kensyuu_sub_id
                WHERE ${(ki !== '000' && `kensyuu2ki(m.kensyuu_id) = '${ki}'`) || ` TRUE `}
                    AND m.shain_cd IN (${shainCDList.join(', ')})
            `
            return db.postgre.run(kensyuuQuery)
        })
        .then((kensyuuResult) => {
            if (kensyuuResult.rows.length === 0) throw 'No kensyuu data'
            let koushinshaCDList = []
            kensyuuData = kensyuuResult.rows
            kensyuuData.forEach((value) => koushinshaCDList.push(value.koushinsha))
            koushinshaCDList = koushinshaCDList.filter((value, key, self) => (value && self.indexOf(value) === key) || false)
            const koushinshaSQL = `
                SELECT shain_cd,
                    (shain_sei || '　' || shain_nm) AS shain_mei
                FROM M_SHAIN
                WHERE shain_cd IN (${(koushinshaCDList.length > 0 && koushinshaCDList.map((i) => `'${i}'`).join(', ')) || `''`})
            `
            return db.oracle.run(koushinshaSQL)
        })
        .then((koushinshaResult) => {
            const koushinshaData = koushinshaResult.rows
            return kensyuuData
                .map((kensyuuItem) => {
                    const foundKoushinsha = koushinshaData.find((koushinshaItem) => koushinshaItem.shain_cd === kensyuuItem.koushinsha)
                    kensyuuItem.koushinsha_nm = (foundKoushinsha && foundKoushinsha.shain_mei) || ''
                    return kensyuuItem
                })
                .map((kensyuuItem) => {
                    const foundShainData = shainData.find((shainItem) => kensyuuItem.shain_cd === shainItem.shain_cd)
                    return Object.assign(kensyuuItem, foundShainData)
                })
        })
        .then((exportData) => {
            const active_sheet = workbook.init()
            const startRow = 3
            let index = 0
            for (const item of exportData) {
                const row = startRow + index
                active_sheet.getCell(`A${row}`).value = index + 1
                active_sheet.getCell(`B${row}`).value = ki
                active_sheet.getCell(`C${row}`).value = item.kensyuu_id || '-'
                active_sheet.getCell(`D${row}`).value = item.kensyuu_mei || '-'
                active_sheet.getCell(`E${row}`).value = common.status.getName(item.status) || ''
                active_sheet.getCell(`F${row}`).value = (item.nittei_from && dateFormat(item.nittei_from, 'yyyy/mm/dd')) || '-'
                active_sheet.getCell(`G${row}`).value = toukyou_oosaka_flag[item.toukyou_oosaka_flag]
                active_sheet.getCell(`H${row}`).value = item.basho || '-'
                active_sheet.getCell(`I${row}`).value = item.jyukouryou !== null ? Number(item.jyukouryou) : 0
                active_sheet.getCell(`J${row}`).value = item.tema_category || '-'
                active_sheet.getCell(`K${row}`).value = item.taishosha_level || '-'
                active_sheet.getCell(`L${row}`).value = item.shukankikan || '-'
                active_sheet.getCell(`M${row}`).value = (item.moushikomi_date && dateFormat(item.moushikomi_date, 'yyyy/mm/dd')) || '-'
                active_sheet.getCell(`N${row}`).value = item.shain_cd || '-'
                active_sheet.getCell(`O${row}`).value = item.shain_mei || '-'
                active_sheet.getCell(`P${row}`).value = item.shain_mei_kana || '-'
                active_sheet.getCell(`Q${row}`).value = item.honbu_nm || '-'
                active_sheet.getCell(`R${row}`).value = item.bumon_nm || '-'
                active_sheet.getCell(`S${row}`).value = item.group_nm || '-'
                active_sheet.getCell(`T${row}`).value = item.yakushoku_nm || '-'
                active_sheet.getCell(`U${row}`).value = item.koushinsha_nm || '-'
                active_sheet.getCell(`V${row}`).value = (item.koushinbi && dateFormat(item.koushinbi, 'yyyy/mm/dd')) || '-'
                active_sheet.getCell(`W${row}`).value = item.bikou || '-'
                workbook.copyStyle(2, row)
                index++
            }
            workbook.removeWorksheet(workbook.option.style)
            return workbook.xlsx.writeFile(filename_out)
        })
        .then(() =>
            res.download(filename_out, (err) => {
                if (err) throw err
                fs.unlink(filename_out, (mistake) => {
                    if (mistake) throw mistake
                })
            })
        )
        .catch((err) => res.download(template))
})

router.post('/import', upload.single('fileupload'), (req, res) => {
    const temp = path.join(__dirname, `../uploads/${req.file.filename}`)
    const file_path = path.join(__dirname, '../uploads/' + 'employee-history.xlsx')
    const importData = []
    fs.renameSync(temp, file_path)
    const workbook = new Workbook()
    workbook.xlsx
        .readFile(file_path)
        .then(() => {
            const workSheet = workbook.getWorksheet('受講履歴 (社員別)')
            const allMoushikomiQuery = `SELECT * FROM tbl_moushikomi`
            workSheet.eachRow(
                {
                    includeEmpty: true,
                },
                (row, rowNumber) => {
                    if (rowNumber < 3) return
                    const rowData = row.values
                    importData.push({
                        shain_cd: `${rowData[6].toString().trim()}`,
                        kensyuu_id: `${rowData[2].toString().trim()}`,
                        kensyuu_sub_id: `${rowData[3].trim()}`,
                        moushikomi_date: `${(rowData[5] && `${dateFormat(rowData[5], 'yyyy-mm-dd HH:MM:ss')}`) || dateFormat(new Date(), 'yyyy-mm-dd HH:MM:ss')}`,
                        status: common.status.getName(rowData[4]),
                        koushinsha: `${rowData[7] || ''}`,
                        koushinbi: `${(rowData[8] && `${dateFormat(rowData[8], 'yyyy-mm-dd HH:MM:sso')}`) || dateFormat(new Date(), 'yyyy-mm-dd HH:MM:sso')}`,
                    })
                }
            )
            return db.postgre.run(allMoushikomiQuery)
        })
        .then((allMoushikomiResult) => {
            let importQuery = `
        INSERT INTO tbl_moushikomi(shain_cd, kensyuu_id, kensyuu_sub_id, moushikomi_date, status, koushinsha, koushinbi)
        VALUES
      `
            const allMoushikomi = allMoushikomiResult.rows

            const filteredImportData = importData.filter((data) => {
                const foundDuplicate = allMoushikomi.find((mou) => {
                    return mou.shain_cd === data.shain_cd && mou.kensyuu_id === data.kensyuu_id && mou.kensyuu_sub_id === data.kensyuu_sub_id && mou.status === data.status
                })
                if (foundDuplicate) return false
                return true
            })
            if (filteredImportData.length === 0) return
            filteredImportData.forEach(
                (rowData) =>
                    (importQuery += `('${rowData.shain_cd || ''}',
          '${rowData.kensyuu_id || ''}',
          '${rowData.kensyuu_sub_id || ''}',
          '${rowData.moushikomi_date || ''}',
          '${rowData.status}',
          '${rowData.koushinsha || ''}',
          '${rowData.koushinbi || ''}'
        ), `)
            )
            importQuery = importQuery.substr(0, importQuery.length - 2)
            return db.postgre.run(importQuery)
        })
        .then(() => {
            return res.status(200).json({
                success: true,
            })
        })
        .catch((err) => {
            return res.status(500).json({
                success: false,
            })
        })
})

router.post('/get-info', (req, res) => {
    const { shain_cd } = req.body
    const query = `
    SELECT *
    FROM (${queryService.shainInfo()}) s
    WHERE s.shain_cd = '${shain_cd}'
  `
    db.oracle
        .run(query)
        .then((result) => {
            const info = (result.rows.length && result.rows[0]) || {}
            return res.status(200).json(info)
        })
        .catch((err) => {
            return res.status(500).json({
                err,
            })
        })
})

router.post('/get-training-list', function(req, res) {
    const { shain_cd } = req.body
    //Update By TheDao
//     const training_query = `
//     SELECT
//         m.shain_cd,
//         v.kensyuu_id,
//         v.kensyuu_mei,
//         v.tema_category,
//         v.shukankikan,
//         v.taishosha_level,
//         v.taishosha,
//         v.nittei_from,
//         v.kensyuu_sub_id,
//         v.nittei_id,
//         v.skill_mg_flag,
//         v.skill_hm_flag,
//         v.skill_tc_flag,
//         v.skill_oa_flag,
//         m.status,
//         m.koushinsha
//     FROM view_kensyuu AS v
//     LEFT JOIN tbl_moushikomi m
//         ON m.kensyuu_id = v.kensyuu_id AND m.kensyuu_sub_id = v.kensyuu_sub_id
//     WHERE m.shain_cd = '${shain_cd}'
//   `
const training_query = `
    SELECT
        m.shain_cd,
        v.kensyuu_id,
        v.kensyuu_mei,
        v.tema_category,
        v.shukankikan,
        v.taishosha_level,
        v.taishosha,
        v.nittei_from,
        v.kensyuu_sub_id,
        v.nittei_id,
        m.status,
        m.koushinsha
    FROM view_kensyuu AS v
    LEFT JOIN tbl_moushikomi m
        ON m.kensyuu_id = v.kensyuu_id AND m.kensyuu_sub_id = v.kensyuu_sub_id
    WHERE m.shain_cd = '${shain_cd}'
  `
    //End Update By TheDao
    const name_query = `SELECT shain_cd, (shain_sei || '　' || shain_nm) shain_mei FROM m_shain`
    Promise.all([db.postgre.run(training_query), db.oracle.run(name_query)])
        .then((result) => {
            const [training_list, name_list] = result.map((i) => i.rows)
            return training_list.map((item) => {
                const found = name_list.find((shain) => shain.shain_cd == item.koushinsha)
                item.nittei_from = (item.nittei_from && moment(new Date(item.nittei_from)).format('YYYY/MM/DD')) || ''
                item.koushinsha_nm = (found !== undefined && found.shain_mei) || ''
                return item
            })
        })
        .then((data) => {
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

module.exports = router
