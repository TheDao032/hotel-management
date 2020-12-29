const express = require('express')

const router = express.Router()
const moment = require('moment')
const path = require('path')
const fs = require('fs')
const dateFormat = require('dateformat')
const { SuperWorkbook } = require('../services/excelService')
const db = require('../models/db')
const common = require('../common')
const { fn } = require('../common')
const queryService = require('../services/queryService')
const authenticationService = require('../services/authenticationService')

router.get('/download-anketto', (req, res) => {
    const file_path = path.join(__dirname, '../uploads/アンケート.xlsx')
    res.download(file_path)
})

router.post('/download-hyouka', (req, res) => {
    const { ankettoID } = req.body
    const template = ankettoID ? path.join(__dirname, '../templates/exports/anketto-detail.xlsx') : path.join(__dirname, '../templates/exports/anketto-all.xlsx')
    const now = new Date().valueOf()
    const filename_out = path.join(__dirname, `../tmp/${now}.xlsx`)
    let finalData
    const workbook = new SuperWorkbook({
        active: 'アンケート',
        style: 'style',
        col: {
            s: 1,
            e: 9,
        },
    })
    const query = `
    SELECT hk.anketto_koutae,
      hk.created_at AS kaito_create_at,
      m.shain_cd,
      m.kensyuu_id,
      m.kensyuu_sub_id,
      vk.kensyuu_mei,
      vk.anketto_id,
      vk.nittei_from,
      vk.nittei_to,
      ak.anketto_naiyou
    FROM tbl_hyouka hk
    LEFT JOIN tbl_moushikomi m
      ON m.moushikomi_id = hk.moushikomi_id
    LEFT JOIN view_kensyuu vk
      ON  vk.kensyuu_id = m.kensyuu_id
      AND vk.kensyuu_sub_id = m.kensyuu_sub_id
      ${(ankettoID && `AND vk.anketto_id = '${ankettoID}'`) || ''}
    LEFT JOIN tbl_anketto ak
      ON ak.anketto_id = vk.anketto_id
    WHERE vk.anketto_id IS NOT NULL
    ORDER by vk.anketto_id;
  `
    Promise.all([db.postgre.run(query), workbook.xlsx.readFile(template)])
        .then(([data]) => {
            finalData = data.rows
            const shainCdList = data.rows.map((i) => i.shain_cd).map((i) => authenticationService.getShainName(i))
            return Promise.all(shainCdList)
        })
        .then((shainMeiList) => {
            return finalData.map((value, index) =>
                Object.assign(value, {
                    shain_mei: shainMeiList[index],
                })
            )
        })
        .then((excelData) => {
            let newExcelData = excelData
            if (ankettoID) {
                newExcelData = newExcelData.filter((value) => value.anketto_id === ankettoID)
            }
            if (newExcelData.length === 0) throw new Error('データがありません。')
            const active_sheet = workbook.init()
            const TITLE_ROW = 2
            const HEADER_ROW = 4
            const START_ROW = HEADER_ROW + 1
            const fixedHeaderColumnAmount = 9
            const beginColToInsertKaito = fixedHeaderColumnAmount + 1 + (ankettoID ? 0 : 1)
            let maxKaito = 0
            newExcelData.forEach((data) => (maxKaito = data.anketto_koutae.length > maxKaito ? data.anketto_koutae.length : maxKaito))

            if (ankettoID) active_sheet.getCell(`A${TITLE_ROW}`).value = `${ankettoID}アンケート回答結果`

            let index = 0
            for (const item of newExcelData) {
                const currentRow = START_ROW + index
                active_sheet.getRow(currentRow).getCell(1).value = index + 1
                active_sheet.getRow(currentRow).getCell(2).value = item.shain_cd || ''
                active_sheet.getRow(currentRow).getCell(3).value = item.shain_mei || ''
                active_sheet.getRow(currentRow).getCell(4).value = (item.nittei_from && moment(new Date(item.nittei_from)).format('YYYY/MM/DD')) || ''
                active_sheet.getRow(currentRow).getCell(5).value = (item.nittei_to && moment(new Date(item.nittei_to)).format('YYYY/MM/DD')) || ''
                active_sheet.getRow(currentRow).getCell(6).value = (item.kaito_create_at && moment(new Date(item.kaito_create_at)).format('YYYY/MM/DD')) || ''
                active_sheet.getRow(currentRow).getCell(7).value = item.kensyuu_id || ''
                active_sheet.getRow(currentRow).getCell(8).value = item.kensyuu_sub_id || ''
                active_sheet.getRow(currentRow).getCell(9).value = item.kensyuu_mei || ''

                // If export anketto all: column 10 is anketto ID
                if (!ankettoID) active_sheet.getRow(currentRow).getCell(fixedHeaderColumnAmount + 1).value = item.anketto_id

                item.anketto_koutae.forEach((kaitoData, kaitoIndex) => {
                    active_sheet.getRow(currentRow).getCell(beginColToInsertKaito + kaitoIndex).value = kaitoData.kaito
                })
                workbook.copyStyle(4, currentRow)
                index++
            }
            // Them vao header kaito con thieu
            for (let currentKaito = 0; currentKaito <= maxKaito - 1; currentKaito++) {
                active_sheet.getRow(HEADER_ROW).getCell(beginColToInsertKaito + currentKaito).value = ankettoID ? `${newExcelData[0].anketto_naiyou[currentKaito].mondai}` : `回答${currentKaito + 1}`
            }
            // Format normal cells & header
            workbook.copyOneStyleToRectangularZone('A2', [beginColToInsertKaito - (ankettoID ? 0 : 1), START_ROW], [beginColToInsertKaito + maxKaito, START_ROW + newExcelData.length])
            workbook.copyOneStyleToRectangularZone('C2', [beginColToInsertKaito, HEADER_ROW], [beginColToInsertKaito + maxKaito, HEADER_ROW])

            workbook.removeWorksheet(workbook.option.style)
            return workbook.xlsx.writeFile(filename_out)
        })
        .then(() =>
            res.download(filename_out, function(err) {
                fs.unlink(filename_out, function(mistake) {})
            })
        )
        .catch(() => {
            workbook.removeWorksheet(workbook.option.style)
            return workbook.xlsx.writeFile(filename_out)
        })
        .then(() =>
            res.download(filename_out, function(err) {
                fs.unlink(filename_out, function(mistake) {})
            })
        )
})

router.post('/kensyuu-list', (req, res) => {
    //Update By TheDao
    // const { holding_date_from, holding_date_to, location, tema_category, skills, kensyuu, taishosha_level, taishosha, shukankikan, kensyuu_category, ki } = req.body
    const { holding_date_from, holding_date_to, location, tema_category, kensyuu, taishosha_level, taishosha, shukankikan, kensyuu_category, ki } = req.body

    const query = `
    SELECT
      nittei_from, basho, moushikomikigen, cancel_date,
      kensyuu_mei, tema_category, taishosha_level, shukankikan,
    FROM view_kensyuu
    WHERE ${(ki !== '000' && `kensyuu2ki(kensyuu_id) = '${ki}'`) || ` TRUE `}
    ${(kensyuu_category !== '-1' && `AND kensyuu_category = '${kensyuu_category}'`) || ''}
    ${(holding_date_from && ` AND ((nittei_from >= '${dateFormat(holding_date_from, 'yyyy/mm/dd')}') OR (nittei_from IS NULL AND nittei_to IS NULL  ))`) || ''}
    ${(holding_date_to && ` AND ((nittei_from <= '${dateFormat(holding_date_to, 'yyyy/mm/dd')}') OR (nittei_from IS NULL AND nittei_to IS NULL  ))`) || ''}
    ${(location.length > 0 && ` AND toukyou_oosaka_flag IN (${location} )`) || ''}
    ${(tema_category !== '-1' && ` AND tema_category = '${tema_category}' `) || ''}
    ${(taishosha_level !== '-1' && ` AND position('${taishosha_level.trim().toLowerCase()}' in lower(taishosha_level)) > 0 `) || ''}
    ${(shukankikan !== '-1' && ` AND position('${shukankikan.trim().toLowerCase()}' in lower(shukankikan)) > 0 `) || ''}
    ${(taishosha !== '-1' && ` AND position('${taishosha.trim().toLowerCase()}' in lower(taishosha)) > 0 `) || ''}
    ${(kensyuu && ` AND (position('${kensyuu.trim().toLowerCase()}' in lower(kensyuu_mei)) > 0 OR kensyuu_id = '${kensyuu}') `) || ''}
    ORDER BY kensyuu_id asc, kensyuu_sub_id asc;
  `
    const template = path.join(__dirname, '../templates/exports/kensyuu_ichiran.xlsx')
    const now = new Date().valueOf()
    const filename_out = path.join(__dirname, `../tmp/${now}.xlsx`)
    // let workbook = new Excel.Workbook()
    const workbook = new SuperWorkbook({
        active: '研修一覧',
        style: 'style',
        col: {
            s: 1,
            e: 9,
        },
    })
    Promise.all([db.postgre.run(query), workbook.xlsx.readFile(template)])
        .then(([rs]) => rs.rows)
        .then((list) => {
            if (list.length === 0) throw new Error('データがありません。')
            const active_sheet = workbook.init()
            const START_ROW = 6
            let index = 0
            list = list.reverse()
            for (const item of list) {
                const row = START_ROW + index
                active_sheet.getCell(`A${row}`).value = index + 1
                active_sheet.getCell(`B${row}`).value = item.kensyuu_mei || ''
                // active_sheet.getCell(`C${row}`).value = (item.skill_mg_flag != 0 && '●') || ''
                // active_sheet.getCell(`D${row}`).value = (item.skill_hm_flag != 0 && '●') || ''
                // active_sheet.getCell(`E${row}`).value = (item.skill_tc_flag != 0 && '●') || ''
                // active_sheet.getCell(`F${row}`).value = (item.skill_oa_flag != 0 && '●') || ''
                active_sheet.getCell(`C${row}`).value = (item.nittei_from && moment(new Date(item.nittei_from)).format('YYYY/MM/DD')) || ''
                active_sheet.getCell(`D${row}`).value = item.basho || ''
                active_sheet.getCell(`E${row}`).value = item.tema_category || ''
                active_sheet.getCell(`F${row}`).value = item.taishosha_level || ''
                active_sheet.getCell(`G${row}`).value = item.shukankikan || ''
                active_sheet.getCell(`H${row}`).value = (item.moushikomikigen && moment(new Date(item.moushikomikigen)).format('YYYY/MM/DD')) || ''
                active_sheet.getCell(`I${row}`).value = (item.cancel_date && moment(new Date(item.cancel_date)).format('YYYY/MM/DD')) || ''
                workbook.copyStyle(4, row)
                index++
            }
            //End Update By TheDao
            // format dong cuoi
            const row = list.length - 1 + START_ROW
            workbook.copyStyle(7, row)
            workbook.removeWorksheet(workbook.option.style)
            return workbook.xlsx.writeFile(filename_out)
        })
        .then(() =>
            res.download(filename_out, function(err) {
                fs.unlink(filename_out, function(mistake) {})
            })
        )
        .catch((err) =>
            res.status(500).json({
                err,
            })
        )
})

router.post('/shonin', (req, res) => {
    const { ki, honbu_cd, bumon_cd, group_cd, kensyuu_mei, status, shain_cd, shain_mei, kensyuubi_from, kensyuubi_to } = req.body

    // query filter all kensyuu list registered by condition
    //     const tbl_moushikomi = `
    //     SELECT d1.*
    //     FROM tbl_moushikomi d1
    //     LEFT OUTER JOIN tbl_moushikomi d2
    //       ON (
    //         d1.moushikomi_date < d2.moushikomi_date
    //         AND d1.shain_cd = d2.shain_cd
    //         AND d1.kensyuu_id = d2.kensyuu_id
    //         AND d1.kensyuu_sub_id = d2.kensyuu_sub_id
    //       )
    //     WHERE
    //       d2.moushikomi_date is null
    //       AND ${(ki !== '000' && `kensyuu2ki(d1.kensyuu_id) = '${ki}'`) || ` TRUE `}
    //       AND d1.status=${(status === '-' && 'd1.status') || status}
    //   `
    const tbl_moushikomi = `
        SELECT d1.*
        FROM tbl_moushikomi d1
        LEFT OUTER JOIN tbl_moushikomi d2
        ON (
            d1.moushikomi_date < d2.moushikomi_date
            AND d1.shain_cd = d2.shain_cd
            AND d1.kensyuu_id = d2.kensyuu_id
            AND d1.kensyuu_sub_id = d2.kensyuu_sub_id
        )
        WHERE
        d2.moushikomi_date is null
            AND ${(ki !== '000' && `kensyuu2ki(d1.kensyuu_id) = '${ki}'`) || ` TRUE `}
            --AND ${(status !== '-1' && `d1.status =${status}`) || `TRUE`}
            AND d1.status=${(status === '-1' && 'd1.status') || status}
    `
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
      ${kensyuubi_from && ` AND '${kensyuubi_from}' <= k.nittei_from `}
      ${kensyuubi_to && ` AND k.nittei_from <= '${kensyuubi_to}'`}
    ORDER BY mo.status ASC, k.nittei_from ASC
  `
    const template = path.join(__dirname, '../templates/exports/kensyuu_shonin.xlsx')
    const now = new Date().valueOf()
    const filename_out = path.join(__dirname, `../tmp/${now}.xlsx`)
    const workbook = new SuperWorkbook({
        active: '研修承認',
        style: 'style',
        col: {
            s: 1,
            e: 16,
        },
    })
    Promise.all([db.postgre.run(query), workbook.xlsx.readFile(template)])
        .then(([rs]) => {
            if (rs.rows.length === 0) return [[], []]
            const data = rs.rows.map((item) => {
                item.nittei_from = (item.nittei_from && moment(new Date(item.nittei_from)).format('YYYY/MM/DD')) || ''
                item.moushikomikigen = (item.moushikomikigen && moment(new Date(item.moushikomikigen)).format('YYYY/MM/DD')) || ''
                item.cancel_date = (item.cancel_date && moment(new Date(item.cancel_date)).format('YYYY/MM/DD')) || ''
                return item
            })

            const shain_list = data
                .map((item) => item.shain_cd)
                .map((item) => `'${item}'`)
                .join(',')
            const shain_info = `
        SELECT *
        FROM (${queryService.shainInfo()}) SHAIN_LIST
        WHERE
        ${(!shain_cd && `SHAIN_CD IN (${shain_list})`) || `INSTR(SHAIN_CD, '${shain_cd.trim()}') > 0`}
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
                    const findShain = info.rows.find((row) => row.shain_cd == item.shain_cd) || info.defaultRow
                    item.shain_mei = findShain.shain_mei
                    item.shain_mei_kana = findShain.shain_mei_kana
                    item.bumon_nm = findShain.bumon_nm
                    return item
                })
                .filter((item) => item.shain_mei)
            return full_data
        })

        .then((data) => {
            const active_sheet = workbook.init()
            const START_ROW = 5
            let index = 0
            for (const item of data) {
                const row = START_ROW + index
                active_sheet.getCell(`A${row}`).value = index + 1
                active_sheet.getCell(`B${row}`).value = common.status.getName(item.status) || ''
                active_sheet.getCell(`C${row}`).value = item.shain_cd || ''
                active_sheet.getCell(`D${row}`).value = item.shain_mei || ''
                active_sheet.getCell(`E${row}`).value = item.shain_mei_kana || ''
                active_sheet.getCell(`F${row}`).value = Number(item.jyukouryou || '')
                active_sheet.getCell(`G${row}`).value = item.bumon_nm || ''
                active_sheet.getCell(`H${row}`).value = item.kensyuu_id || ''
                active_sheet.getCell(`I${row}`).value = item.kensyuu_mei || ''
                active_sheet.getCell(`J${row}`).value = (item.nittei_from && moment(new Date(item.nittei_from)).format('YYYY/MM/DD')) || ''
                active_sheet.getCell(`K${row}`).value = item.basho || ''
                active_sheet.getCell(`L${row}`).value = item.tema_category || ''
                active_sheet.getCell(`M${row}`).value = item.taishosha_level || ''
                active_sheet.getCell(`N${row}`).value = item.shukankikan || ''
                active_sheet.getCell(`O${row}`).value = (item.moushikomikigen && moment(new Date(item.moushikomikigen)).format('YYYY/MM/DD')) || ''
                active_sheet.getCell(`P${row}`).value = (item.cancel_date && moment(new Date(item.cancel_date)).format('YYYY/MM/DD')) || ''
                workbook.copyStyle(4, row)
                index++
            }
            // format dong cuoi
            const f_row = data.length - 1 + START_ROW
            if (f_row > 4) workbook.copyStyle(7, f_row)
            workbook.removeWorksheet(workbook.option.style)
            return workbook.xlsx.writeFile(filename_out)
        })
        .then(() => {
            return res.download(filename_out, function(err) {
                fs.unlink(filename_out, function(mistake) {})
            })
        })
        .catch((err) => {
            return res.status(500).json({
                data: [],
                err,
            })
        })
})

module.exports = router
