setupMockServer = ->
  server = sinon.fakeServer.create()
  server.autoRespond = true
  server.xhr.useFilters = true
  server.xhr.addFilter (method, url) -> !!url.match(/visualEditor/) || !!url.match(/visual-editor/)
  server

# server.respondWith 'GET', '/event_stream', [
#   400
#   'Content-Type': 'application/json'
#   JSON.stringify {}
# ]
#
# server.respondWith 'GET', '/admin/journals/authorization', [
#   204
#   'Content-Type': 'application/html'
#   ""
# ]
#
# # papers/:id/manuscript_manager
# server.respondWith 'GET', /\/papers\/\d+\/manuscript_manager/, [
#   403
#   {}
#   JSON.stringify {}
# ]
#
# server.respondWith 'GET', "/users/#{@currentUserId}", [
#   200
#   'Content-Type': 'application/json'
#   JSON.stringify {user: @fakeUser}
# ]
#
# server.respondWith 'GET', "/comment_looks", [
#   200
#   'Content-Type': 'application/json'
#   JSON.stringify {comment_looks: []}
# ]
#
# server.respondWith 'GET', '/user_flows/authorization', [
#   403, 'content-type': 'application/html', 'tahi-authorization-check': true, ""
# ]
#
# server.respondWith 'GET', '/formats', [
#   200,
#   {"Content-Type": "application/json"},
#   JSON.stringify({
#     "export_formats": [{ "format": "docx" }, { "format": "latex" }],
#     "import_formats": [{ "format": "docx" }, { "format": "odt" }]
#   })
# ]

`export default setupMockServer`
