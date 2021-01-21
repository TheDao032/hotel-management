const express = require('express')
const API = express.Router()
const homePageController = require('../controllers/homePageController')
const maintainceRouter = require('../controllers/maintaince/')
const settingsController = require('../controllers/settingsController')
const employeeController = require('../controllers/employeeController')
const accountController = require('../controllers/accountController')
const roomController = require('../controllers/roomController')
const customerController = require('../controllers/customerController')
const checkinController = require('../controllers/checkinController')
const foodController = require('../controllers/foodController')

// new or fixed
API.use('/home', homePageController)

API.use('/maintaince', maintainceRouter)

API.use('/settings', settingsController)

API.use('/emp', employeeController)

API.use('/room', roomController)

API.use('/cus', customerController)

API.use('/acc', accountController)

API.use('/check-in', checkinController)

API.use('/food', foodController)

module.exports = API
