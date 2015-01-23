`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import { paperWithTask } from '../helpers/setups'`
`import setupMockServer from '../helpers/mock-server'`
`import Factory from '../helpers/factory'`

app = null
server = null
fakeUser = null
currentPaper = null

module 'Integration: EditPaper',

  teardown: ->
    server.restore()
    Ember.run(app, app.destroy)

  setup: ->
    app = startApp()
    server = setupMockServer()
    fakeUser = window.currentUser.user

    figureTaskId = 94139

    records = paperWithTask('FigureTask'
      id: figureTaskId
      role: "author"
    )

    [currentPaper, figureTask, journal, litePaper, phase] = records

    paperPayload = Factory.createPayload('paper')
    paperPayload.addRecords(records.concat([fakeUser]))
    paperResponse = paperPayload.toJSON()

    taskPayload = Factory.createPayload('task')
    taskPayload.addRecords([figureTask, litePaper, fakeUser])
    figureTaskResponse = taskPayload.toJSON()

    collaborators = [
      id: "35"
      full_name: "Aaron Baker"
      info: "testroles2, collaborator"
    ]

    server.respondWith 'GET', "/papers/#{currentPaper.id}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]
    server.respondWith 'GET', "/tasks/#{figureTaskId}", [
      200, {"Content-Type": "application/json"}, JSON.stringify figureTaskResponse
    ]
    server.respondWith 'PUT', /\/tasks\/\d+/, [
      204, {"Content-Type": "application/json"}, JSON.stringify {}
    ]
    server.respondWith 'GET', /\/filtered_users\/users\/\d+/, [
      200, {"Content-Type": "application/json"}, JSON.stringify []
    ]

test 'visiting /edit-paper: Author completes all metadata cards', ->
  visit "/papers/#{currentPaper.id}/edit"
  .then -> ok find('a:contains("Submit")').hasClass 'button--disabled'
  .then ->
    for card in find('#paper-metadata-tasks .card-content')
      click card
      click '#task_completed'
      click '.overlay-close-button:first'
  .then -> ok !find('a:contains("Submit")').hasClass 'button--disabled'

test 'on paper.edit when paper.editable changes, user transitions to paper.index', ->
  visit "/papers/#{currentPaper.id}/edit"
  .then ->
    Ember.run ->
      getStore().getById('paper', currentPaper.id).set('editable', false)
  andThen ->
    ok !find('.button-primary:contains("Submit")').length
    equal currentRouteName(), "paper.index"

test 'on paper.edit when there are no metadata tasks', ->
  expect(2)
  records = paperWithTask('Task'
    id: 2
    role: "admin"
  )

  currentPaper = records[0]
  paperPayload = Factory.createPayload('paper')
  paperPayload.addRecords(records.concat([fakeUser]))
  paperResponse = paperPayload.toJSON()

  server.respondWith 'GET', "/papers/#{currentPaper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
  ]

  visit("/papers/#{currentPaper.id}/edit")
    .then ->
      ok(find('main.sidebar-empty').length, "The sidebar should be hidden")
    .then ->
      msg = "There is a submit manuscript button in the main area"
      ok(find('.edit-paper .no-sidebar-submit-manuscript.button--green:contains("Submit Manuscript")').length, msg)

test 'on paper.index when there are no metadata tasks', ->
  expect(2)
  records = paperWithTask('Task'
    id: 2
    role: "admin"
  )

  currentPaper = records[0]
  paperPayload = Factory.createPayload('paper')
  paperPayload.addRecords(records.concat([fakeUser]))
  paperResponse = paperPayload.toJSON()

  server.respondWith 'GET', "/papers/#{currentPaper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
  ]

  visit "/papers/#{currentPaper.id}/edit"
  .then ->
    Ember.run ->
      getStore().getById('paper', currentPaper.id).set('editable', false)
  andThen ->
    ok find('main.sidebar-empty').length, "The sidebar should be hidden"
    msg = "There is no submit manuscript button in the main area"
    ok !find('.edit-paper .no-sidebar-submit-manuscript.button--green:contains("Submit Manuscript")').length, msg
