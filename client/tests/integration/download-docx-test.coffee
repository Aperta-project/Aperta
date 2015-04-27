`import Ember from 'ember'`
`import { test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`
`import { paperWithTask } from '../helpers/setups'`
`import setupMockServer from '../helpers/mock-server'`
`import Factory from '../helpers/factory'`
`import Utils from 'tahi/services/utils'`

app = null
server = null
currentPaper = null
fakeUser = null
exportUrl = null

module 'Integration: Paper Docx Download',
  teardown: ->
    server.restore()
    Ember.run(app, app.destroy)

  setup: ->
    app = startApp()
    server = setupMockServer()
    fakeUser = window.currentUserData.user

test 'show download links on control bar', ->
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

  jobId = '232134-324-1234-1234'
  exportUrl = "/api/papers/#{currentPaper.id}/export?format=docx"

  server.respondWith 'GET', "/api/papers/#{currentPaper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify(paperResponse)
  ]
  server.respondWith 'GET', exportUrl, [
    200, {"Content-Type": "application/json"}, JSON.stringify({job: { id: "#{jobId}" }})
  ]
  server.respondWith 'GET', "/api/papers/#{currentPaper.id}/status/#{jobId}", [
    200, {"Content-Type": "application/json"}, JSON.stringify({
      "job": {
        "state": "completed",
        "id": "#{jobId}",
        "outputs": []
      }
    })
  ]

  mock = undefined
  visit "/papers/#{currentPaper.id}/edit"

  andThen ->
    mock = sinon.mock(Utils)
    mock.expects("windowLocation").withArgs("https://www.google.com").returns(true)

  click('.downloads-link').then ->
    click('.docx')

  andThen ->
    ok _.findWhere(server.requests, { method: 'GET', url: exportUrl }), 'Download request made'
    mock.restore()
