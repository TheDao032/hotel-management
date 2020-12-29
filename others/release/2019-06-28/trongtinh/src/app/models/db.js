const pg = require('pg')
const fs = require('fs')
const path = require('path')
    // pg setting type parsing
const { types } = pg
const timestampOID = 1114
const timestamptzOID = 1184
const dateOID = 1082
types.setTypeParser(timestampOID, (v) => v)
types.setTypeParser(timestamptzOID, (v) => v)
types.setTypeParser(dateOID, (v) => v)

const oracledb = require('oracledb')
const environments = require('../environments/environment')

const attribule = {
    user: environments.configOCDatabaseAD.user,
    password: environments.configOCDatabaseAD.password,
    connectString: environments.configOCDatabaseAD.connectionString,
}

const postgre = {
    run(query) {
        const pool = new pg.Pool(environments.configDatabase)
        let poolClient = null
        let result = null
        let error = null
        return pool
            .connect()
            .then((pc) => (poolClient = pc))
            .then(() => poolClient.query(query))
            .then((rs) => (result = rs))
            .catch((e) => (error = e))
            .then(() => {
                if (poolClient !== null)
                    poolClient.release((err) => {
                        if (err) {
                            // cant not release PoolClient
                        }
                    })
                if (error !== null) {
                    // query fail
                    throw error
                }
                // Filelog
                const now = new Date()
                const subFile = `/logs/${now.getMonth() + 1}${now.getFullYear()}postgrelog.txt`
                const content = now + query
                const file = path.join(__dirname, subFile)
                try {
                    fs.appendFileSync(file, content)
                } catch (err) {
                    console.error(err)
                }

                return result
            })
    },
}

const oracle = {
    run(query) {
        const queryOption = {
            outFormat: oracledb.OBJECT,
        }
        let connection = null
        let result = null
        let error = null
        return oracledb
            .getConnection(attribule)
            .then((conn) => {
                connection = conn
            })
            .then(() => connection.execute(query, {}, queryOption))
            .then((rs) => (result = rs))
            .catch((err) => (error = err))
            .then(() => {
                if (connection !== null)
                    connection.close((err) => {
                        if (err) {
                            // cant not release PoolClient
                        }
                    })
                if (error !== null) {
                    // query fail
                    throw error
                }
                // handle result
                result.defaultRow = {}
                result.metaData = result.metaData.map((item) => {
                    item.name = item.name.toLowerCase()
                    result.defaultRow[item.name] = null
                    return item
                })
                result.rows = result.rows.map((item) => {
                    const obj = {}
                    Object.keys(item).map((k, v) => (obj[k.toLowerCase()] = item[k]))
                    return obj
                })

                // Filelog
                const now = new Date()
                const subFile = `/logs/${now.getMonth() + 1}${now.getFullYear()}oraclelog.txt`

                const content = now + query
                const file = path.join(__dirname, subFile)
                try {
                    fs.appendFileSync(file, content)
                        // file written successfully
                } catch (err) {
                    console.error(err)
                }
                return result
            })
    },
}

module.exports = {
    postgre,
    oracle,
}
