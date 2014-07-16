@mockEventStreamResponse = ->
  @server.respondWith 'GET', '/event_stream', [
    400
    'Content-Type': 'application/json'
    JSON.stringify {}
  ]

@mockAuthorizedRouteReponse = ->
  @server.respondWith 'GET', '/admin/journals', [
    403
    'Tahi-Authorization-Check': 'true'
    JSON.stringify {}
  ]

  # papers/:id/manuscript_manager
  @server.respondWith 'GET', /\/papers\/\d+\/manuscript_manager/, [
    403
    'Tahi-Authorization-Check': 'true'
    JSON.stringify {}
  ]

@mockCurrentUserResponse = ->
  @server.respondWith 'GET', "/users/#{@currentUserId}", [
    200
    'Content-Type': 'application/json'
    JSON.stringify @fakeUser
  ]

@setupMockServer = ->
  @server.restore() if @server
  @server = sinon.fakeServer.create()
  @server.autoRespond = true
  @server.xhr.useFilters = true
  @server.xhr.addFilter (method, url) -> !!url.match(/visual-editor/)
  @mockCurrentUserResponse()
  @mockAuthorizedRouteReponse()
  @mockEventStreamResponse()
