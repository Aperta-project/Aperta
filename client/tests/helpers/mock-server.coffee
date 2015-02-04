setupMockServer = ->
  server = sinon.fakeServer.create()
  server.autoRespond = true
  server.xhr.useFilters = true

  # TODO: require visual editor as a pkg once the team can provide one
  #
  # visual editor unfortunately lives in public
  # We don't care about its JSON dependencies
  #
  server.xhr.addFilter (method, url) -> !!url.match(/visualEditor/)
  server.respondWith 'GET', /visual-editor/, '{}'

  server.respondWith 'GET', '/formats', [
    200, {"Content-Type": "application/json"}, JSON.stringify({
      "export_formats": ["docx", "latex"],
      "import_formats": ["docx", "odt"]
    })
  ]

  server.respondWith 'GET', '/flows/authorization', [
    204, 'content-type': 'application/html', 'tahi-authorization-check': true, ""
  ]
  server.respondWith 'GET', '/user_flows/authorization', [
    204, 'content-type': 'application/html', 'tahi-authorization-check': true, ""
  ]
  server.respondWith 'GET', '/admin/journals/authorization', [
    204, 'content-type': 'application/html', 'tahi-authorization-check': true, ""
  ]
  server.respondWith 'GET', "/comment_looks", [
    200, 'Content-Type': 'application/json', JSON.stringify {comment_looks: []}
  ]
  server.respondWith 'GET', /\/papers\/\d+\/manuscript_manager/, [
    403, {}, JSON.stringify({})
  ]

  server

`export default setupMockServer`
