// code taken from https://glebbahmutov.com/blog/how-to-correctly-unit-test-express-server/
const express = require('express')
const app = express()
app.get('/', function (req, res) {
  res.status(200).send('ok')
})
const server = app.listen(6000, () => {
  const port = server.address().port
  console.log('Listening on port %s', port)
})
module.exports = server
