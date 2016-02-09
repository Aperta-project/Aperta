export default function() {
  let server = sinon.fakeServer.create();
  server.autoRespond = true;
  server.xhr.useFilters = true;

  server.respondWith('GET', '/api/flows/authorization', [
    204, { 'content-type': 'application/html', 'tahi-authorization-check': true }, ''
  ]);

  server.respondWith('GET', '/api/user_flows/authorization', [
    204, { 'content-type': 'application/html', 'tahi-authorization-check': true }, ''
  ]);

  server.respondWith('GET', '/api/admin/journals/authorization', [
    204, { 'content-type': 'application/html', 'tahi-authorization-check': true }, ''
  ]);

  server.respondWith('GET', '/api/comment_looks', [
    200, { 'Content-Type': 'application/json' },
    JSON.stringify({ comment_looks: [] })
  ]);

  server.respondWith('GET', RegExp("/api/permissions/(.*)%2B(\\d+)"), function (xhr, object, id) {
    json = JSON.stringify({permissions:[{ id:''+object+'%2B'+id , permissions:[]}]})
    xhr.respond(200, { 'Content-Type': 'application/json' }, json)
  });

  server.respondWith(
    'GET',
    /\/api\/papers\/\d+\/manuscript_manager/,
    [403, {}, JSON.stringify({})]
  );

  return server;
}
