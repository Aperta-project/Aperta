`import Ember from 'ember'`
`import { test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`
`import { paperWithTask, addUserAsParticipant, addUserAsCollaborator } from '../helpers/setups'`
`import setupMockServer from '../helpers/mock-server'`
`import Factory from '../helpers/factory'`
`import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';`

app = null
server = null
fakeUser = null
currentPaper = null

module 'Integration: EditPaper',

  afterEach: ->
    server.restore()
    Ember.run(-> TestHelper.teardown() )
    Ember.run(app, app.destroy)

  beforeEach: ->
    app = startApp()
    server = setupMockServer()
    fakeUser = window.currentUserData.user
    TestHelper.handleFindAll('discussion-topic', 1)

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

    server.respondWith 'GET', "/api/papers/#{currentPaper.id}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]
    server.respondWith 'GET', "/api/tasks/#{figureTaskId}", [
      200, {"Content-Type": "application/json"}, JSON.stringify figureTaskResponse
    ]
    server.respondWith 'PUT', /\/api\/tasks\/\d+/, [
      204, {"Content-Type": "application/json"}, JSON.stringify {}
    ]
    server.respondWith 'GET', /\/api\/filtered_users\/users\/\d+/, [
      200, {"Content-Type": "application/json"}, JSON.stringify []
    ]

test 'on paper.index as a participant on a task but not author of paper', (assert) ->
  expect(1)

  records = paperWithTask('Task'
    id: 1
    title: 'ReviewMe'
    role: 'reviewer'
  )

  [currentPaper, task, journal, litePaper, phase] = records

  paperPayload = Factory.createPayload('paper')
  paperPayload.addRecords(records.concat([fakeUser]))
  paperResponse = paperPayload.toJSON()
  paperResponse.participations = [addUserAsParticipant(task, fakeUser)]

  server.respondWith 'GET', "/api/papers/#{currentPaper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
  ]

  visit("/papers/#{currentPaper.id}/edit").then ->
    assert.ok !!find('#paper-assigned-tasks .card-content:contains("ReviewMe")').length

test 'on paper.index as a participant on a task and author of paper', (assert) ->
  expect(1)

  records = paperWithTask('ReviseTask'
    id: 1
    qualifiedType: "TahiStandardTasks::ReviseTask"
    role: 'author'
  )

  [currentPaper, task, journal, litePaper, phase] = records

  paperPayload = Factory.createPayload('paper')
  paperPayload.addRecords(records.concat([fakeUser]))
  paperResponse = paperPayload.toJSON()
  paperResponse.participations = [addUserAsParticipant(task, fakeUser)]
  paperResponse.collaborations = [addUserAsCollaborator(currentPaper, fakeUser)]

  server.respondWith 'GET', "/api/papers/#{currentPaper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
  ]

  visit("/papers/#{currentPaper.id}/edit").then ->
    assert.ok !!find('#paper-assigned-tasks .card-content:contains("Revise Task")'),
      "Participant task is displayed in '#paper-assigned-tasks' for author"

test 'visiting /edit-paper: Author completes all metadata cards', (assert) ->
  expect(3)
  visit("/papers/#{currentPaper.id}/edit")
    .then ->
      assert.ok(!find('#paper-container.sidebar-empty').length, "The sidebar should NOT be hidden")
    .then ->
      submitButton = find('button:contains("Submit")')
      assert.ok(!submitButton.length, "Submit is disabled")
    .then ->
      for card in find('#paper-metadata-tasks .card-content')
        click card
        click '#task_completed'
        click '.overlay-close-button:first'
  andThen ->
    submitButton = find('button:contains("Submit")')
    assert.ok(!submitButton.hasClass('button--disabled'), "Submit is enabled")

test 'on paper.index when paper.editable changes, user transitions to paper.index', (assert) ->
  visit "/papers/#{currentPaper.id}/edit"
  .then ->
    Ember.run ->
      getStore().getById('paper', currentPaper.id).set('editable', false)
  andThen ->
    assert.ok !find('.button-primary:contains("Submit")').length
    assert.equal currentRouteName(), "paper.index.index"

test 'on paper.index when there are no metadata tasks', (assert) ->
  expect(2)
  records = paperWithTask('Task'
    id: 2
    role: "admin"
  )

  currentPaper = records[0]
  paperPayload = Factory.createPayload('paper')
  paperPayload.addRecords(records.concat([fakeUser]))
  paperResponse = paperPayload.toJSON()

  server.respondWith 'GET', "/api/papers/#{currentPaper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
  ]

  visit("/papers/#{currentPaper.id}/edit")
    .then ->
      !assert.ok(find('#paper-container.sidebar-empty').length, "The sidebar should be hidden")
    .then ->
      msg = "There is a submit manuscript button in the main area"
      assert.ok(find('.no-sidebar-submit-manuscript.button--green:contains("Submit Manuscript")').length, msg)


test 'on paper.index when there are no metadata tasks', (assert) ->
  expect(2)
  records = paperWithTask('Task'
    id: 3
    role: "admin"
  )

  currentPaper = records[0]
  paperPayload = Factory.createPayload('paper')
  paperPayload.addRecords(records.concat([fakeUser]))
  paperResponse = paperPayload.toJSON()

  server.respondWith 'GET', "/api/papers/#{currentPaper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
  ]

  visit "/papers/#{currentPaper.id}/edit"
  .then ->
    Ember.run ->
      getStore().getById('paper', currentPaper.id).set('editable', false)

  andThen ->
    assert.ok find('#paper-container.sidebar-empty').length, "The sidebar should be hidden"
    msg = "There is no submit manuscript button in the main area"
    assert.ok !find('.manuscript-container .no-sidebar-submit-manuscript.button--green:contains("Submit Manuscript")').length, msg
