`import Ember from 'ember'`
`import { test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`
`import { paperWithTask, addUserAsParticipant, addUserAsCollaborator, addNestedQuestionToTask } from '../helpers/setups'`
`import setupMockServer from '../helpers/mock-server'`
`import Factory from '../helpers/factory'`
`import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';`

app = null
server = null
fakeUser = null
currentPaper = null

module 'Integration: PaperIndex',

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
      oldRole: "author"
    )

    [currentPaper, figureTask, journal, phase] = records

    nestedQuestion = Factory.createRecord('NestedQuestion', { ident: 'figures--complies' })
    addNestedQuestionToTask(nestedQuestion, figureTask)

    paperPayload = Factory.createPayload('paper')
    paperPayload.addRecords(records.concat([fakeUser]))
    paperResponse = paperPayload.toJSON()

    tasksPayload = Factory.createPayload('tasks')
    tasksPayload.addRecords([figureTask])
    console.log tasksPayload.toJSON()

    taskPayload = Factory.createPayload('task')
    taskPayload.addRecords([figureTask, currentPaper, fakeUser, nestedQuestion])

    figureTaskResponse = taskPayload.toJSON()
    collaborators = [
      id: "35"
      full_name: "Aaron Baker"
      info: "testroles2, collaborator"
    ]

    server.respondWith 'GET', "/api/papers/#{currentPaper.id}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]
    server.respondWith 'GET', "/api/papers/#{currentPaper.id}/tasks", [
      200, {"Content-Type": "application/json"}, JSON.stringify tasksPayload.toJSON()
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
    server.respondWith 'GET', "/api/tasks/#{figureTaskId}/nested_questions", [
      200, {"Content-Type": "application/json"} , JSON.stringify({nested_questions: [nestedQuestion]})
    ]
    server.respondWith 'GET', "/api/tasks/#{figureTaskId}/nested_question_answers", [
      200, {"Content-Type": "application/json"} , JSON.stringify({nested_question_answers: []})
    ]
    server.respondWith 'GET', "/api/journals", [
      200, {'Content-Type': 'application/json'}, JSON.stringify({journals:[]})
    ]


test 'on paper.index as a participant on a task but not author of paper', (assert) ->
  expect(1)

  records = paperWithTask('Task'
    id: 1
    title: 'ReviewMe'
    oldRole: 'reviewer'
  )

  [currentPaper, task, journal, litePaper, phase] = records

  paperPayload = Factory.createPayload('paper')
  paperPayload.addRecords(records.concat([fakeUser]))
  paperResponse = paperPayload.toJSON()
  paperResponse.participations = [addUserAsParticipant(task, fakeUser)]

  server.respondWith 'GET', "/api/papers/#{currentPaper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
  ]

  visit("/papers/#{currentPaper.id}").then ->
    assert.ok !!find('#paper-assigned-tasks .task-disclosure-heading:contains("ReviewMe")').length

test 'on paper.index as a participant on a task and author of paper', (assert) ->
  expect(1)

  records = paperWithTask('ReviseTask'
    id: 1
    qualifiedType: "TahiStandardTasks::ReviseTask"
    oldRole: 'author'
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

  visit("/papers/#{currentPaper.id}").then ->
    assert.ok !!find('#paper-assigned-tasks .card-content:contains("Revise Task")'),
      "Participant task is displayed in '#paper-assigned-tasks' for author"

test 'visiting /paper: Author completes all metadata cards', (assert) ->
  expect(3)
  visit("/papers/#{currentPaper.id}")
    .then ->
      assert.ok(!find('#paper-container.sidebar-empty').length, "The sidebar should NOT be hidden")
    .then ->
      submitButton = find('button:contains("Submit")')
      assert.ok(!submitButton.length, "Submit is disabled")
    .then ->
      for card in find('#paper-submission-tasks .card-content')
        click card
        click '.task-completed'
        click '.overlay-close-button:first'
  andThen ->
    submitButton = find('button:contains("Submit")')
    assert.notOk(submitButton.hasClass('button--disabled'), "Submit is enabled")
