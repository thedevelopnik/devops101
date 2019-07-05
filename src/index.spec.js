// code taken from https://glebbahmutov.com/blog/how-to-correctly-unit-test-express-server/
const request = require('supertest')

describe('server', () => {
  let server
  before(() => {
    server = require('./index')
  })
  after((done) => {
    server.close(done)
  })
  it('responds to /', (done) => {
    request(server)
      .get('/')
      .expect(200, done)
  })
  it('404 everything else', (done) => {
    request(server)
      .get('/foo/bar')
      .expect(404, done);
  })
})
