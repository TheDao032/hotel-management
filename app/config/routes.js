// route
const express = require('express')

const router = express.Router()

const path = require('path')
const authentication = require('../middlewares/authentication')
const log = require('../middlewares/log')

// log
router.use(log)

// new authencation
const authenticationController = require('../controllers/authenticationController')

router.use('/api/authentication', authenticationController)

// API
const API = require('./api')

router.use('/api', authentication.verifyToken, API)

// render
router.get('/*', (req, res) => res.sendFile(path.join(__dirname, '../public/index.html')))
router.get(/.*/, (req, res) =>
    res.status(404).json({
        msg: 404,
    })
)

// export
module.exports = router
