/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

export default function() {
  let server = sinon.fakeServer.create();
  server.autoRespond = true;
  server.xhr.useFilters = true;

  server.respondWith('GET', '/api/admin/journals/authorization', [
    204, { 'content-type': 'application/html', 'tahi-authorization-check': true }, ''
  ]);

  server.respondWith('GET', '/api/comment_looks', [
    200, { 'Content-Type': 'application/json' },
    JSON.stringify({ comment_looks: [] })
  ]);

  server.respondWith('GET', RegExp("/api/permissions/(.*)%2B(\\d+)"), function (xhr, object, id) {
    const json = JSON.stringify({permissions:[{ id:''+object+'+'+id , permissions:[]}]});
    xhr.respond(200, { 'Content-Type': 'application/json' }, json);
  });

  /* ^^ can be done with $.mockjax as follows if you don't wish to use sinon for your test:
  $.mockjax({
    type: 'GET',
    url: RegExp('/api/permissions/(.*)%2B(\\d+)'),
    urlParams: ['object', 'id'],
    status: 200,
    response: function(settings) {
      let { object, id } = settings;
      const json = JSON.stringify({
        permissions: [{ id: '' + object + '+' + id, permissions: [] }]
      });
      this.responseText = json;
    }
  });
  */

  return server;
}
