'use strict';

describe('API', () => {
  var request = require('request');
  var url = 'http://localhost:3010/';

  describe('GET /users', () => {
    it('returns a 200 status code', (done) => {
      request.get(`${url}users`, (err, res, body) => {
        expect(res.statusCode).toBe(200);
        done();
      });
    });
  });
});