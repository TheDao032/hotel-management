const express = require('express')

const router = express.Router()
const db = require('../../models/db')

router.post('/get', (req, res) => {
    const { kensyuu_id } = req.body
    const queryKensyuu = `
    SELECT * FROM tbl_kensyuu_master WHERE kensyuu_id = '${kensyuu_id}'`
    db.postgre
        .run(queryKensyuu)
        .then((result) => {
            if (result.rows.length === 0) throw 'Cannot get kensyuu'
            else {
                const queryKensyuuSub = `
          SELECT * FROM tbl_kensyuu_nittei_master
          WHERE kensyuu_id = '${kensyuu_id}'
          ORDER BY kensyuu_sub_id
          `
                return Promise.all([result.rows, db.postgre.run(queryKensyuuSub)])
            }
        })
        .then(([kensyuuData, kensyuuSub]) =>
            res.status(200).json({
                success: true,
                data: {
                    kensyuu: kensyuuData,
                    kensyuu_sub: kensyuuSub.rows,
                },
            })
        )
        .catch((err) =>
            res.status(500).json({
                success: false,
                err,
            })
        )
})

router.post('/all', (req, res) => {
    const { ki } = req.body
    //Update By TheDao
    // const query = `
    //     SELECT
    //     k.kensyuu_id, k.kensyuu_mei, k.kensyuu_category, k.flag,
    //     k.skill_mg_flag, k.skill_hm_flag, k.skill_tc_flag, k.skill_oa_flag,
    //     k.kensyuu_gaiyou, k.taishosha_level, k.taishosha, k.jyukouryou,
    //     k.shukankikan, bikou, k.anketto_id, k.tema_category, count_nittei.count as count_nittei
    //     FROM tbl_kensyuu_master k
    //     LEFT JOIN (
    //     SELECT kensyuu_id, COUNT(kensyuu_id) as count
    //     FROM tbl_kensyuu_nittei_master
    //     GROUP BY kensyuu_id
    //     ORDER BY kensyuu_id ASC
    //     ) count_nittei
    //     ON k.kensyuu_id = count_nittei.kensyuu_id
    //     WHERE kensyuu2ki(k.kensyuu_id) = '${ki}'
    //     ORDER BY k.kensyuu_id ASC;
    // `
    const query = `
        SELECT
        k.kensyuu_id, k.kensyuu_mei, k.kensyuu_category, k.flag,
        k.kensyuu_gaiyou, k.taishosha_level, k.taishosha, k.jyukouryou,
        k.shukankikan, bikou, k.anketto_id, k.tema_category, count_nittei.count as count_nittei
        FROM tbl_kensyuu_master k
        LEFT JOIN (
        SELECT kensyuu_id, COUNT(kensyuu_id) as count
        FROM tbl_kensyuu_nittei_master
        GROUP BY kensyuu_id
        ORDER BY kensyuu_id ASC
        ) count_nittei
        ON k.kensyuu_id = count_nittei.kensyuu_id
        WHERE kensyuu2ki(k.kensyuu_id) = '${ki}'
        ORDER BY k.kensyuu_id ASC;
    `
    db.postgre
        .run(query)
        .then((result) =>
            res.status(200).json({
                success: true,
                data: result.rows || [],
            })
        )
        .catch((err) =>
            res.status(500).json({
                success: false,
            })
        )
})

router.post('/insert-or-update', (req, res) => {
    // const { kensyuu_id, kensyuu_mei, kensyuu_category, taishosha_level, taishosha, tema_category, skill_mg_flag, skill_hm_flag, skill_oa_flag, skill_tc_flag, kensyuu_gaiyou, jyukouryou, shukankikan, bikou, flag, isInsert } = req.body
    const { kensyuu_id, kensyuu_mei, kensyuu_category, taishosha_level, taishosha, tema_category, kensyuu_gaiyou, jyukouryou, shukankikan, bikou, flag, isInsert } = req.body

    const anketto_id = (req.body.anketto_id && `'${req.body.anketto_id}'`) || null
    if (isInsert) {
        const checkExistKensyuuIDQuery = `SELECT * FROM tbl_kensyuu_master WHERE kensyuu_id = '${kensyuu_id}'`
        db.postgre
            .run(checkExistKensyuuIDQuery)
            .then((checkDuplicateResult) => {
                if (checkDuplicateResult.rows.length > 0) {
                    res.status(500).json({
                        success: false,
                        isDuplicate: true,
                    })
                    return ''
                }
        //         const insertNewKensyuuQuery = `
        //   INSERT INTO tbl_kensyuu_master(
        //     kensyuu_id,
        //     kensyuu_mei,
        //     kensyuu_category,
        //     taishosha_level,
        //     taishosha,
        //     tema_category,
        //     skill_mg_flag,
        //     skill_hm_flag,
        //     skill_tc_flag,
        //     skill_oa_flag,
        //     kensyuu_gaiyou,
        //     jyukouryou,
        //     shukankikan,
        //     bikou,
        //     anketto_id,
        //     flag)
        //   VALUES(
        //     '${kensyuu_id.trim()}',
        //     '${kensyuu_mei.trim()}',
        //     '${kensyuu_category.trim()}',
        //     '${taishosha_level.trim()}',
        //     '${taishosha.trim()}',
        //     '${tema_category.trim()}',
        //     ${skill_mg_flag ? 1 : 0}::bit(1),
        //     ${skill_hm_flag ? 1 : 0}::bit(1),
        //     ${skill_tc_flag ? 1 : 0}::bit(1),
        //     ${skill_oa_flag ? 1 : 0}::bit(1),
        //     '${kensyuu_gaiyou.trim()}',
        //     '${jyukouryou.trim()}',
        //     '${shukankikan.trim()}',
        //     '${bikou.trim()}',
        //     ${anketto_id},
        //     ${flag}) RETURNING *
        //   `
        const insertNewKensyuuQuery = `
          INSERT INTO tbl_kensyuu_master(
            kensyuu_id,
            kensyuu_mei,
            kensyuu_category,
            taishosha_level,
            taishosha,
            tema_category,
            kensyuu_gaiyou,
            jyukouryou,
            shukankikan,
            bikou,
            anketto_id,
            flag)
          VALUES(
            '${kensyuu_id.trim()}',
            '${kensyuu_mei.trim()}',
            '${kensyuu_category.trim()}',
            '${taishosha_level.trim()}',
            '${taishosha.trim()}',
            '${tema_category.trim()}',
            '${kensyuu_gaiyou.trim()}',
            '${jyukouryou.trim()}',
            '${shukankikan.trim()}',
            '${bikou.trim()}',
            ${anketto_id},
            ${flag}) RETURNING *
          `
                return db.postgre.run(insertNewKensyuuQuery)
            })
            .then((resultInsertNewKensyuu) => {
                if (!resultInsertNewKensyuu) return ''
                if (resultInsertNewKensyuu.rowCount === 0) throw new Error('Cannot insert new kensyuu')
                res.status(200).json({
                    success: true,
                })
            })
            .then(() => {
                const sqlSelect = `SELECT *
                FROM public.tbl_kyouiku_shukankikan where name_shukankikan = '${shukankikan.trim()}'`
                db.postgre
                    .run(sqlSelect)
                    .then((result) => {
                        if (result.rows.length === 0) {
                            const sqlInsert = `INSERT INTO public.tbl_kyouiku_shukankikan(
                                                    name_shukankikan, mail_shukankikan)
                                                VALUES ('${shukankikan.trim()}',null)
                                                RETURNING * ;`
                            db.postgre.run(sqlInsert).then((result1) => {
                                if (result1.rows.length === 0) {
                                    return res.status(200).json({
                                        code: 2,
                                    })
                                }
                                return res.status(200).json({
                                    code: 0,
                                })
                            })
                        }
                    })
                    .catch(() => {
                        res.status(200).json({
                            code: 4,
                        })
                    })
            })
            .catch((err) => {
                if (err)
                    res.status(500).json({
                        success: false,
                    })
            })
    } else {
        // const updateKensyuuQuery = `
        //     UPDATE tbl_kensyuu_master
        //     SET	kensyuu_mei = '${kensyuu_mei.trim()}',
        //         kensyuu_category = '${kensyuu_category}',
        //         taishosha_level = '${taishosha_level}',
        //         taishosha = '${taishosha}',
        //         tema_category = '${tema_category}',
        //         skill_mg_flag = ${skill_mg_flag ? 1 : 0}::bit(1),
        //         skill_hm_flag = ${skill_hm_flag ? 1 : 0}::bit(1),
        //         skill_tc_flag = ${skill_tc_flag ? 1 : 0}::bit(1),
        //         skill_oa_flag = ${skill_oa_flag ? 1 : 0}::bit(1),
        //         kensyuu_gaiyou = '${kensyuu_gaiyou}',
        //         jyukouryou = '${jyukouryou}',
        //         shukankikan = '${shukankikan}',
        //         bikou = '${bikou}',
        //         anketto_id = ${anketto_id},
        //         flag = ${flag}
        //     WHERE kensyuu_id = '${kensyuu_id}' RETURNING *
        // `
        const updateKensyuuQuery = `
            UPDATE tbl_kensyuu_master
            SET	kensyuu_mei = '${kensyuu_mei.trim()}',
                kensyuu_category = '${kensyuu_category}',
                taishosha_level = '${taishosha_level}',
                taishosha = '${taishosha}',
                tema_category = '${tema_category}',
                kensyuu_gaiyou = '${kensyuu_gaiyou}',
                jyukouryou = '${jyukouryou}',
                shukankikan = '${shukankikan}',
                bikou = '${bikou}',
                anketto_id = ${anketto_id},
                flag = ${flag}
            WHERE kensyuu_id = '${kensyuu_id}' RETURNING *
        `
        //End Update By TheDao
        db.postgre
            .run(updateKensyuuQuery)
            .then((result) => {
                if (result.rowCount == 0) throw 'Cannot update tbl_kensyuu_master'
                res.status(200).json({
                    success: true,
                })
            })
            .then(() => {
                const sqlSelect = `SELECT *
                FROM public.tbl_kyouiku_shukankikan where name_shukankikan = '${shukankikan.trim()}'`
                db.postgre.run(sqlSelect).then((result1) => {
                    if (result1.rows.length === 0) {
                        const sqlInsert = `
                            INSERT INTO public.tbl_kyouiku_shukankikan(name_shukankikan, mail_shukankikan)
                            VALUES ('${shukankikan.trim()}',null) RETURNING * ;
                        `
                        db.postgre.run(sqlInsert).then((result2) => {
                            if (result2.rows.length === 0) {
                                return res.status(200).json({
                                    code: 2,
                                })
                            }
                            return res.status(200).json({
                                code: 0,
                            })
                        })
                    }
                })
            })
            .catch((err) => {
                res.status(500).json({
                    success: false,
                    err,
                })
            })
    }
})

router.get('/get-taishosha-taishoshalevel', (req, res) => {
    const taishoshaQuery = `SELECT DISTINCT taishosha from tbl_kensyuu_master ORDER BY taishosha ASC`
    const taishoshaLevelQuery = `SELECT DISTINCT taishosha_level from tbl_kensyuu_master ORDER BY taishosha_level ASC`
    Promise.all([db.postgre.run(taishoshaQuery), db.postgre.run(taishoshaLevelQuery)])
        .then((result) => {
            const taishoshaList = result[0].rows.sort((a, b) => (a.taishosha > b.taishosha ? 1 : a.taishosha === b.taishosha ? 0 : -1))
            const taishoshaLevelList = result[1].rows
            res.status(200).json({
                success: true,
                taishoshaList,
                taishoshaLevelList,
            })
        })
        .catch((err) =>
            res.status(500).json({
                success: false,
            })
        )
})

module.exports = router
