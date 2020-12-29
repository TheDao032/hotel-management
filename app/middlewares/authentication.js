const jwt = require('jsonwebtoken')

const authenticationService = require('../services/authenticationService')
// const passport = require('passport')
const environments = require('../environments/environment')

const verifyToken = (req, res, next) => {
    req.user = undefined
    if (!req.headers || !req.headers.authorization)
        return res.status(401).json({
            err: 'Unauthorized User!',
            code: 7, //
        })

    const token = req.headers.authorization
    return jwt.verify(token, environments.secret, (err, decode) => {
        if (err)
            return res.status(401).json({
                err,
                code: 6, //
            })
        // passport.authenticate('jwt', { session: false })
        const user = decode
        return authenticationService
            .getPermission(user.shain_cd)
            .then((permission_cd) => {
                user.permission_cd = permission_cd
                req.user = user
            })
            .catch(() =>
                res.status(401).json({
                    err,
                    code: 6, //
                })
            )
            .then(next)
    })
}

const credentials = {
    client: {
        id: environments.APP_ID,
        secret: environments.APP_PASSWORD,
    },
    auth: {
        tokenHost: 'https://login.microsoftonline.com',
        authorizePath: 'common/oauth2/v2.0/authorize',
        tokenPath: 'common/oauth2/v2.0/token',
    },
}
const oauth2 = require('simple-oauth2').create(credentials)

function getAuthUrl() {
    const returnVal = oauth2.authorizationCode.authorizeURL({
        redirect_uri: environments.REDIRECT_URI,
        scope: environments.APP_SCOPES,
    })
    console.log(`Generated auth url: ${returnVal}`)
    return returnVal
}

function saveValuesToCookie(token, res) {
    // Parse the identity token
    const user = jwt.decode(token.token.id_token)

    // Save the access token in a cookie
    res.cookie('graph_access_token', token.token.access_token, { maxAge: 3600000, httpOnly: false })
    // Save the user's name in a cookie
    res.cookie('graph_user_name', user.name, { maxAge: 3600000, httpOnly: false })
    // Save the refresh token in a cookie
    res.cookie('graph_refresh_token', token.token.refresh_token, { maxAge: 7200000, httpOnly: false })
    // Save the token expiration time in a cookie
    res.cookie('graph_token_expires', token.token.expires_at.getTime(), { maxAge: 3600000, httpOnly: false })
}

async function getTokenFromCode(auth_code, res) {
    const result = await oauth2.authorizationCode.getToken({
        code: auth_code,
        redirect_uri: environments.REDIRECT_URI,
        scope: environments.APP_SCOPES,
    })

    const token = oauth2.accessToken.create(result)
    // console.log('Token created: ', token.token)

    saveValuesToCookie(token, res)

    return token.token
}

function clearCookies(res) {
    // Clear cookies
    res.clearCookie('graph_access_token', { maxAge: 3600000, httpOnly: true })
    res.clearCookie('graph_user_name', { maxAge: 3600000, httpOnly: true })
    res.clearCookie('graph_refresh_token', { maxAge: 7200000, httpOnly: true })
    res.clearCookie('graph_token_expires', { maxAge: 3600000, httpOnly: true })
}

async function getAccessToken(data, res) {
    // Do we have an access token cached?
    const token = data.access_token
    if (token) {
        // We have a token, but is it expired?
        // Expire 5 minutes early to account for clock differences
        const newDate = new Date(data.expires_at).getTime()
        const FIVE_MINUTES = 300000
        const expiration = new Date(parseFloat(newDate - FIVE_MINUTES))
        if (expiration > new Date()) {
            // Token is still good, just return it
            return token
        }
    }

    // Either no token or it's expired, do we have a
    // refresh token?
    const refreshToken = data.refresh_token
    if (refreshToken) {
        const newToken = await oauth2.accessToken.create({ refresh_token: refreshToken }).refresh()
        // saveValuesToCookie(newToken, res)
        return newToken.token.access_token
    }

    // Nothing in the cookies that helps, return empty
    return null
}

// exports.getAccessToken = getAccessToken

// exports.clearCookies = clearCookies

// exports.getTokenFromCode = getTokenFromCode

// exports.getAuthUrl = getAuthUrl

module.exports = {
    verifyToken,
    getAccessToken,
    clearCookies,
    getTokenFromCode,
    getAuthUrl,
}
