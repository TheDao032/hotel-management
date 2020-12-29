module.exports = function(req, res, next) {
    // const oldWrite = res.write
    // const oldEnd = res.end
    // const chunks = []
    // res.write = function (chunk) {
    //   chunks.push(chunk)
    //   oldWrite.apply(res, arguments)
    // }
    // res.end = function (chunk) {
    //   if (chunk) chunks.push(chunk)
    //   const body = Buffer.concat(chunks).toString('utf8')
    //   console.log(req.path, body)
    //   oldEnd.apply(res, arguments)
    // }
    // res.send('500 (Internal Server Error)')
    // if (req.path === '/api/training/get-registered-list') res.status(500).json({err: 'ahihi'})
    next()
}
