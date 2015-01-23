`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import setupMockServer from '../helpers/mock-server'`
`import { paperWithTask } from '../helpers/setups'`
`import Factory from '../helpers/factory'`

app = null
server = null
fakeUser = null
currentPaper = null

module 'Integration: Submitting Paper',
  teardown: ->
    server.restore()
    Ember.run(app, app.destroy)

  setup: ->
    app = startApp()
    server = setupMockServer()
    fakeUser = window.currentUser.user

    records = paperWithTask('Task'
      id: 1
      title: "Metadata"
      isMetadataTask: true
      completed: true
    )
    currentPaper = records[0]

    paperPayload = Factory.createPayload('paper')
    paperPayload.addRecords(records.concat([fakeUser]))
    paperResponse = paperPayload.toJSON()

    server.respondWith 'GET', "/papers/#{currentPaper.id}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]

    dashboardResponse =
      dashboards: [
        id: 1
        total_paper_count: 0
        total_page_count: 0
      ]

    server.respondWith 'PUT', "/papers/#{currentPaper.id}", [
      204, {"Content-Type": "application/html"}, ""
    ]

    server.respondWith 'PUT', "/papers/#{currentPaper.id}/submit", [
      200, {"Content-Type": "application/json"}, JSON.stringify({papers: []})
    ]

    server.respondWith 'GET', '/dashboards', [
      200, 'Content-Type': 'application/json', JSON.stringify(dashboardResponse)
    ]

test "User can submit a paper", ->
  expect(1)
  visit("/papers/#{currentPaper.id}/edit")
  click(".edit-paper a:contains('Submit Manuscript')")
  click("button.button-primary")

  andThen ->
    ok _.findWhere(server.requests, {method: "PUT", url: "/papers/#{currentPaper.id}/submit"}), "It posts to the server"
