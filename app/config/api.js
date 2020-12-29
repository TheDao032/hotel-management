/* eslint-disable prettier/prettier */
const express = require('express')

const API = express.Router()

const homePageController = require('../controllers/homePageController')

const maintainceRouter = require('../controllers/maintaince/')
const settingsController = require('../controllers/settingsController')

// new or fixed
API.use('/home', homePageController)

API.use('/maintaince', maintainceRouter)

API.use('/settings', settingsController)

module.exports = API
