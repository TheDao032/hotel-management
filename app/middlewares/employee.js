const environments = require('../environments/environment')
const db = require('../models/db')

const random = (length = 4) => {
    var number = '';
    var characters = '0123456789';
    var charactersLength = characters.length;
    for ( var i = 0; i < length; i++ ) {
        number += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    const result = 'htm' + number
    const queryCheck = `
        SELECT check_existed_id('${result}') as check;
    `
    return db.postgre
        .run(queryCheck)
        .then((result) => {
            return result.rows[0].check
        })
        .catch((err) => {
            return err
        })
}

module.exports = {
    random,
}
