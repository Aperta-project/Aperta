@mockEventStreamResponse = ->
  @server.respondWith 'GET', '/event_stream', [
    400
    'Content-Type': 'application/json'
    JSON.stringify {}
  ]

@mockAuthorizedRouteReponse = ->
  @server.respondWith 'GET', '/admin/journals/authorization', [
    204
    'Content-Type': 'application/html'
    ""
  ]

  # papers/:id/manuscript_manager
  @server.respondWith 'GET', /\/papers\/\d+\/manuscript_manager/, [
    403
    {}
    JSON.stringify {}
  ]

@mockCurrentUserResponse = ->
  @server.respondWith 'GET', "/users/#{@currentUserId}", [
    200
    'Content-Type': 'application/json'
    JSON.stringify {user: @fakeUser}
  ]

@mockCommentLookResponse = ->
  @server.respondWith 'GET', "/comment_looks", [
    200
    'Content-Type': 'application/json'
    JSON.stringify {comment_looks: []}
  ]
@mockFlowManagerAuthResponse = ->
  @server.respondWith 'GET', '/user_flows/authorization', [
    403, 'content-type': 'application/html', 'tahi-authorization-check': true, ""
  ]

# This gives the paper_index_route and paper_edit_route the iHat download info
# they need to show all the download icons. Without this, many tests would 404
@mockFormatsResponse = ->
  @expectedSupportedDownloadFormats = {
    "export_formats": [{ "format": "docx" }, { "format": "latex" }],
    "import_formats": [{ "format": "docx" }, { "format": "odt" }]
  }
  server.respondWith 'GET', '/formats', [
    200,
    {"Content-Type": "application/json"},
    JSON.stringify @expectedSupportedDownloadFormats
  ]

@setupMockServer = ->
  @server.restore() if @server
  @server = sinon.fakeServer.create()
  @server.autoRespond = true
  @server.xhr.useFilters = true
  @server.xhr.addFilter (method, url) -> !!url.match(/visualEditor/) || !!url.match(/visual-editor/)
  @mockCurrentUserResponse()
  @mockAuthorizedRouteReponse()
  @mockEventStreamResponse()
  @mockCommentLookResponse()
  @mockFlowManagerAuthResponse()
  @mockFormatsResponse()
