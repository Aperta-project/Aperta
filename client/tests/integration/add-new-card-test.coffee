`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import { test } from 'ember-qunit'`
`import { paperWithParticipant } from '../helpers/setups'`
`import setupMockServer from '../helpers/mock-server'`

app = null
server = null

module 'Integration: adding a new card',

  teardown: ->
    server.restore()
    Ember.run(app, app.destroy)

  setup: ->
    app = startApp()
    server = setupMockServer()

    adminJournalsResponse =
      admin_journal: {
        id: 1
        name: "Test Journal of America",
        journal_task_type_ids: [1]
      },
      journal_task_types:[{
        id: 1,
        title: "Ad Hoc",
        kind: "Task",
        journal_id: 1
      }]

    taskPayload =
      task:
        id: 2
        title: "Ad Hoc Task"
        type: "Task"
        phase_id: 1
        paper_id: 1
        lite_paper_id: 1

    #let us see the manuscript manager
    server.respondWith 'GET', /\/api\/papers\/\d+\/manuscript_manager/, [
      204, {}, ""
    ]
    server.respondWith 'GET', "\/api\/papers/1", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperWithParticipant().toJSON()
    ]
    server.respondWith 'POST', "\/api\/tasks", [
      200, {"Content-Type": "application/json"}, JSON.stringify taskPayload
    ]
    server.respondWith 'GET', '\/api\/flows/authorization', [
      204, 'content-type': 'application/html', 'tahi-authorization-check': true, ""
    ]
    server.respondWith 'GET', '\/api\/admin/journals/1', [
      200, 'Content-Type': 'application/json', JSON.stringify adminJournalsResponse
    ]

test 'user sees task overlay when the task is added', ->
  visit '/papers/1/workflow'
  click("a:contains('Add New Card')")
  pickFromChosenSingle '.task-type-select', 'Ad Hoc'
  click '.button--green:contains("Add")'
  andThen ->
    ok find('div.overlay-container').length
