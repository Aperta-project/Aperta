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
    json = JSON.stringify({permissions:[{ id:''+object+'+'+id , permissions:[]}]})
    xhr.respond(200, { 'Content-Type': 'application/json' }, json)
  });

  return server;
}
