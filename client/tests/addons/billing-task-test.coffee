`import Ember from 'ember'`
`import { test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`
`import { paperWithTask } from '../helpers/setups'`
`import setupMockServer from '../helpers/mock-server'`
`import Factory from '../helpers/factory'`

app = null
server = null
fakeUser = null
currentPaper = null

module 'Integration: Billing',
  teardown: ->
    server.restore()
    Ember.run(app, app.destroy)
  setup: ->
    app = startApp()
    server = setupMockServer()
    fakeUser = window.currentUser.user

    billingTaskId = 94139

    records = paperWithTask('BillingTask'
      id: billingTaskId
      role: "author"
    )

    [currentPaper, billingTask, journal, litePaper, phase] = records

    paperPayload = Factory.createPayload('paper')
    paperPayload.addRecords(records.concat([fakeUser]))
    paperResponse = paperPayload.toJSON()

    taskPayload = Factory.createPayload('task')
    taskPayload.addRecords([billingTask, litePaper, fakeUser])
    billingTaskResponse = taskPayload.toJSON()

    collaborators = [
      id: "35"
      full_name: "Aaron Baker"
      info: "testroles2, collaborator"
    ]

    server.respondWith 'GET', "/papers/#{currentPaper.id}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]
    server.respondWith 'GET', "/tasks/#{billingTaskId}", [
      200, {"Content-Type": "application/json"}, JSON.stringify billingTaskResponse
    ]
    server.respondWith 'PUT', /\/tasks\/\d+/, [
      204, {"Content-Type": "application/json"}, JSON.stringify {}
    ]
    server.respondWith 'GET', /\/filtered_users\/users\/\d+/, [
      200, {"Content-Type": "application/json"}, JSON.stringify []
    ]

test 'Viewing card', ->
  visit "/papers/#{currentPaper.id}/edit"
  click ':contains(Billing)'
  .then ->
    equal find('h1').text().trim(), 'Publication Fees'
    
