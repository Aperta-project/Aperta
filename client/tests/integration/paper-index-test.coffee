`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import { test } from 'ember-qunit'`

`import { paperWithTask } from '../helpers/setups'`
`import Factory from '../helpers/factory'`
`import setupMockServer from '../helpers/mock-server'`

app = null
server = null
fakeUser = null

module 'Integration: PaperIndex',
  teardown: ->
    server.restore()
    Ember.run(app, 'destroy')

  setup: ->
    app = startApp()
    server = setupMockServer()
    fakeUser = window.currentUserData.user

test 'on paper.index, contributors are visible', ->
  records = paperWithTask('Task'
    id: 2
    role: "admin"
  )

  paperPayload = Factory.createPayload('paper')

  paperPayload.addRecords(records.concat([fakeUser]))
  paperResponse = paperPayload.toJSON()
  paperResponse.paper.submitted = true

  server.respondWith 'GET', "/api/papers/#{records[0].id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
  ]

  visit "/papers/#{records[0].id}"
  andThen ->
    Ember.run ->
      getStore().getById('paper', records[0].id).set('editable', false)
  andThen ->
    click('.contributors-link').then ->
      # using JQuery to select an element (the navbar) outside the QUnit container
      equal $("html.control-bar-sub-nav-active").length, 1
      equal $(".control-bar-sub-items .contributors.active").is(':visible'), true
