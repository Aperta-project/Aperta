module 'Integration: MessageCards',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp(integration: true)

    journalId = 1
    paperId = 1
    phaseId = 1
    messageTaskId = 1
    ef = ETahi.Factory
    paperPayload = ef.createPayload('paper')

    journal = paperPayload.createRecord('journal', id: journalId)
    paper = paperPayload.createRecord('paper',
        id: paperId
        assignee_ids: [fakeUser.id]
        journal_id: journalId
    )

    messageTask = paperPayload.createRecord 'messageTask',
      id: messageTaskId
      title: "Message Time"
      assignee_id: fakeUser.id
      participant_ids: [fakeUser.id]

    phase = paperPayload.createRecord('phase', id: phaseId)

    ef.associatePaperWithPhases(paper, [phase])
    ef.associatePaperWithTasks(paper, [messageTask])
    ef.associatePhaseWithTasks(phase, [messageTask])

    dashboard =
      users: [fakeUser]
      affiliations: []
      lite_papers: [litePaper]
      dashboards: [
        id: 1
        user_id: fakeUser.id
        paper_ids: [paperId]
      ]

    litePaper = ETahi.Factory.createLitePaper(paper)
    paperPayload.addRecord(litePaper)
      .addRecord(fakeUser)

    paperResponse = paperPayload.toJSON()
    server.respondWith 'GET', "/dashboards", [
      200, {"Content-Type": "application/json"}, JSON.stringify dashboard
    ]
    server.respondWith 'GET', "/papers/#{paperId}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]

    server.respondWith 'PUT', /\/tasks\/\d+/, [
      204, {"Content-Type": "application/json"}, JSON.stringify {}
    ]

test 'Showing a message card will work', ->
  expect(1)
  visit '/papers/1/tasks/1'
  .then -> equal(find('.overlay-content h1').text(), "Message Time")

test 'A message card with a comment works', ->
  commentData = ETahi.Factory.create 'comment',
    commenter_id: fakeUser.id
    message_task_id: 1
    created_at: new Date().toISOString()

  foo = pushModel('comment', commentData)
  expect(1)
  visit('/papers/1/tasks/1')
  andThen -> equal(find('.overlay-content h1').text(), "Message Time")
