module 'Integration: adding an adhoc card',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp integration: true

    adminJournalsResponse =
      admin_journal: {
        id: 1
        name: "Test Journal of America",
        journal_task_type_ids: [1]
      },
      journal_task_types:[{
        id: 1,
        title: "Upload Manuscript",
        role: "author",
        kind: "UploadManuscript::Task",
        journal_id: 1
      }]

    taskPayload =
      task:
        id: 2
        title: "Upload Manuscript"
        type: "UploadManuscript::Task"
        phase_id: 1
        paper_id: 1
        lite_paper_id: 1

    #let us see the manuscript manager
    server.respondWith 'GET', /\/papers\/\d+\/manuscript_manager/, [
      204
      'Tahi-Authorization-Check': 'true'
      ""
    ]

    server.respondWith 'GET', "/papers/1", [
      200, {"Content-Type": "application/json"}, JSON.stringify ETahi.Setups.paperWithParticipant().toJSON()
    ]

    server.respondWith 'POST', "/tasks", [
      200, {"Content-Type": "application/json"}, JSON.stringify taskPayload
    ]

    server.respondWith 'GET', '/flows/authorization', [
      204, 'content-type': 'application/html', 'tahi-authorization-check': true, ""
    ]

    server.respondWith 'GET', '/admin/journals/1', [
      200, 'Content-Type': 'application/json', JSON.stringify adminJournalsResponse
    ]

test 'user sees task overlay when the task is added', ->
  visit '/papers/1/manage'
  click("a:contains('Add New Card')")
  pickFromChosenSingle '.task-type-select', 'Upload Manuscript'
  click '.button--green:contains("Add")'
  andThen ->
    ok find('#paper-manuscript-upload').length
