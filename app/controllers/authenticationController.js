const express = require('express')

const router = express.Router()

const jwt = require('jsonwebtoken')
const authenticationService = require('../services/authenticationService')
const authentication = require('../middlewares/authentication')
const environments = require('../environments/environment')

router.post('/login', (req, res) => {
    authenticationService.authenticate(req.body.username, req.body.password, (err, auth = null, user = null) => {
        // console.log(err)
        if (err) {
            console.log(err)
            // const path = require('path')
            // const fs = require('fs')
            //       const content = typeof(err) === 'string' && err || JSON.stringify(err)
            //       const text =
            // `****
            //   username: ${req.body.username}
            //   ${content}
            // ****
            // `
            //       fs.appendFile(path.join(__dirname, `../logs/login.txt`), text, {encoding: 'utf8'}, _ => {})
            res.status(401).json({
                err,
                code: 6,
            })
            return
        }
        console.log(auth)
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
    const { shain_cd, permission_cd } = req.user
    authenticationService
        .getShainName(shain_cd)
        .then((fullname) => {
            return res.json({
                code: 0,
                data: {
                    user: {
                        shain_cd,
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
