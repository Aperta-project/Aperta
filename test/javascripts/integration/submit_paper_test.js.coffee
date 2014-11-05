module 'Integration: Submitting Paper',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp integration: true
    ef = ETahi.Factory
    records = ETahi.Setups.paperWithTask('Task'
      id: 1
      title: "Metadata"
      isMetadataTask: true
      completed: true
    )
    ETahi.Test = {}
    ETahi.Test.currentPaper = records[0]

    paperPayload = ef.createPayload('paper')
    paperPayload.addRecords(records.concat([fakeUser]))
    paperResponse = paperPayload.toJSON()

    server.respondWith 'GET', "/papers/#{ETahi.Test.currentPaper.id}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]

test "User can submit a paper", ->

  ETahi.Test.dashboardResponse =
    dashboards: [
      id: 1
      total_paper_count: 0
      total_page_count: 0
    ]

  server.respondWith 'PUT', "/papers/#{ETahi.Test.currentPaper.id}", [
    204, {"Content-Type": "application/html"}, ""
  ]

  server.respondWith 'PUT', "/papers/#{ETahi.Test.currentPaper.id}/submit", [
    200, {"Content-Type": "application/json"}, JSON.stringify {papers: []}
  ]

  server.respondWith 'GET', '/dashboards', [
    200, 'Content-Type': 'application/json', JSON.stringify ETahi.Test.dashboardResponse
  ]

  visit "/papers/#{ETahi.Test.currentPaper.id}/edit"
  click ".edit-paper a:contains('Submit Manuscript')"
  click "button.button-primary"

  andThen ->
    ok _.findWhere(server.requests, {method: "PUT", url: "/papers/#{ETahi.Test.currentPaper.id}/submit"}), "It posts to the server"
