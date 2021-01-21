const moment = require('moment')
const environments = require('../environments/environment')
const db = require('../models/db')

const costFunc = async (id_food, number) => {
    const costQuery = `
        SELECT price_fo
            FROM tbl_food
        WHERE id_fo = '${id_food}'
    `
    const costResult = await db.postgre.run(costQuery).run(costQuery).catch((err) => {
        return err
    })

    if (!costResult.rows) {
        return
    }
    const price = costResult.rows[0].price_fo
    return number * price
}

module.exports = {
    costFunc
}
