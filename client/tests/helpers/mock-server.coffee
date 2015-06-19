setupMockServer = ->
  server = sinon.fakeServer.create()
  server.autoRespond = true
  server.xhr.useFilters = true

  # TODO: require visual editor as a pkg once the team can provide one
  #
  # visual editor unfortunately lives in public
  # We don't care about its JSON dependencies
  #
  server.xhr.addFilter (method, url) -> !!url.match(/ember-cli-visualeditor\/i18n/)
  server.respondWith 'GET', /ember-cli-visualeditor\/i18n/, '{}'

  server.respondWith 'GET', '/api/flows/authorization', [
    204, 'content-type': 'application/html', 'tahi-authorization-check': true, ""
  ]
  server.respondWith 'GET', '/api/user_flows/authorization', [
    204, 'content-type': 'application/html', 'tahi-authorization-check': true, ""
  ]
  server.respondWith 'GET', '/api/admin/journals/authorization', [
    204, 'content-type': 'application/html', 'tahi-authorization-check': true, ""
  ]
  server.respondWith 'GET', "/api/comment_looks", [
    200, 'Content-Type': 'application/json', JSON.stringify {comment_looks: []}
  ]
  server.respondWith 'GET', /\/api\/papers\/\d+\/manuscript_manager/, [
    403, {}, JSON.stringify({})
  ]

  server

`export default setupMockServer`
