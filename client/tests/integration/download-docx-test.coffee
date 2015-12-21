`import Ember from 'ember'`
`import { test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`
`import { paperWithTask } from '../helpers/setups'`
`import setupMockServer from '../helpers/mock-server'`
`import Factory from '../helpers/factory'`
`import Utils from 'tahi/services/utils'`
`import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';`

app = null
server = null
currentPaper = null
fakeUser = null
exportUrl = null

module 'Integration: Paper Docx Download',
  afterEach: ->
    server.restore()
    Ember.run(-> TestHelper.teardown() )
    Ember.run(app, app.destroy)

  beforeEach: ->
    app = startApp()
    server = setupMockServer()
    fakeUser = window.currentUserData.user
    TestHelper.handleFindAll('discussion-topic', 1)

test 'show download links on control bar', (assert) ->
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
  exportUrl = "/api/papers/#{currentPaper.id}/export?export_format=docx"

  server.respondWith 'GET', "/api/papers/#{currentPaper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify(paperResponse)
  ]
  server.respondWith 'GET', exportUrl, [
    202, {"Content-Type": "application/json"},
      JSON.stringify({url: "/api/papers/#{currentPaper.id}/status/#{jobId}"})
  ]
  server.respondWith 'GET', "/api/papers/#{currentPaper.id}/status/#{jobId}", [
    200, {"Content-Type": "application/json"}, JSON.stringify({
            url: "/api/papers/#{currentPaper.id}/download.docx" })
  ]

  mock = undefined
  visit "/papers/#{currentPaper.id}"

  andThen ->
    mock = sinon.mock(Utils)
    mock.expects("windowLocation").withArgs("/api/papers/" + currentPaper.id + "/download.docx").returns(true)

  click('#nav-downloads').then ->
    click('.docx')

  andThen ->
    assert.ok _.findWhere(server.requests, { method: 'GET', url: exportUrl }), 'Download request made'
    mock.restore()
