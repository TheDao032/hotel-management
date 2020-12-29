/* eslint-disable prettier/prettier */
const express = require('express')
const bodyParser = require('body-parser')
const errorHandler = require('errorhandler')
const morgan = require('morgan')
const cors = require('cors')
const path = require('path')

const server = express()

server.use(cors())
server.use(morgan('dev'))
server.use(bodyParser.json())
server.use(
    bodyParser.urlencoded({
        extended: false,
    })
)

// Set static Folder
server.use(express.static(path.join(__dirname, '../public')))
if (server.get('env') === 'development') server.use(errorHandler())

module.exports = server
