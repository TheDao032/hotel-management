const express = require('express')

const API = express.Router()

const mypageController = require('../controllers/mypageController')
const hyoukaController = require('../controllers/hyoukaController')
const importController = require('../controllers/importController')
const exportController = require('../controllers/exportController')
const kensyuuController = require('../controllers/kensyuu')
const moushikomiController = require('../controllers/moushikomiController')
const commonController = require('../controllers/commonController')

const trainingController = require('../controllers/training')
const employeeController = require('../controllers/employeeController')
const maintainceRouter = require('../controllers/maintaince/')
const settingsController = require('../controllers/settingsController')

// new or fixed
API.use('/employee', employeeController)
API.use('/mypage', mypageController)
API.use('/import', importController)
API.use('/common', commonController)
API.use('/export', exportController)
API.use('/hyouka', hyoukaController)
API.use('/kensyuu', kensyuuController)
API.use('/moushikomi', moushikomiController)

API.use('/training', trainingController)
API.use('/maintaince', maintainceRouter)

API.use('/settings', settingsController)

module.exports = API
