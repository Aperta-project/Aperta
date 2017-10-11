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
