/* eslint-disable no-unused-vars */
const express = require('express')

const router = express.Router()

const jwt = require('jsonwebtoken')
const authenticationService = require('../services/authenticationService')
const authentication = require('../middlewares/authentication')
const environments = require('../environments/environment')

router.post('/login', (req, res) => {
    authenticationService.authenticate(req.body.username, req.body.password, (err, auth = null, user = null) => {
        if (err) {
            res.status(401).json({
                err,
                code: 6,
            })
            return
        }
        const token = jwt.sign(auth, environments.secret, {
            expiresIn: '24h',
            algorithm: 'HS256',
        })
        res.status(200).json({
            code: 0, // login succes
            data: {
                user,
                token,
            },
        })
    })
})

router.post('/verify-token', authentication.verifyToken, (req, res) => {
    const { employee_id, permission_cd } = req.user
    authenticationService
        .getEmployeeName(employee_id)
        .then((fullname) => {
            return res.json({
                code: 0,
                data: {
                    user: {
                        employee_id,
                        permission_cd,
                        fullname,
                    },
                },
            })
        })
        .catch((err) => {
            return res.status(401).json({
                err,
                code: 6,
            })
        })
})

/* GET /authorize. */
router.post('/authorize', async (req, res, next) => {
    // Get auth code
    const { code } = req.body

    // If code is present, use it
    if (code) {
        try {
            const data = await authentication.getTokenFromCode(code, res)
            // Redirect to home
            res.status(200).json({
                code: 0,
                data,
            })
        } catch (error) {
            // res.render('error', { title: 'Error', message: 'Error exchanging code for token', error })
            res.status(400).json({
                code: 1,
                error,
            })
        }
    } else {
        // Otherwise complain
        // res.render('error', { title: 'Error', message: 'Authorization error', error: { status: 'Missing code parameter' } })
        res.status(401).json({
            code: 1,
            error: 'Authorization error: Missing code parameter',
        })
    }
})

/* GET /authorize/signout */
router.get('/signout', (req, res, next) => {
    authentication.clearCookies(res)

    // Redirect to home
    res.redirect('/')
})

/* GET home page. */
router.post('/info', async (req, res, next) => {
    // const parms = { title: 'Home', active: { home: true } }
    const { input } = req.body

    const accessToken = input !== '' ? await authentication.getAccessToken(input.data, res) : ''
    const userName = input !== '' ? jwt.decode(input.data.id_token) : ''

    if (accessToken && userName) {
        // parms.user = userName
        // parms.debug = `User: ${userName}\nAccess Token: ${accessToken}`
        return res.status(200).json({
            code: 0,
            data: {
                userName,
                accessToken,
            },
        })
    }
    const signInUrl = authentication.getAuthUrl()
    // parms.debug = parms.signInUrl
    return res.status(200).json({
        code: 0,
        data: {
            signInUrl,
        },
    })

    // res.render('index', parms)
})

module.exports = router
