/* eslint-disable prettier/prettier */
const express = require('express')

const maintainceRouter = express.Router()

const permissionController = require('./permissionController')

maintainceRouter.use('/permission', permissionController)

module.exports = maintainceRouter
