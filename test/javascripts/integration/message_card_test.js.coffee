module 'Integration: MessageCards',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp(integration: true)

    journalId = 1
    paperId = 1
    phaseId = 1
    messageTaskId = 1
    paperPayload = ETahi.Factory.createPayload('paper')

    journal = paperPayload.createRecord('journal', id: journalId)
    paper = paperPayload.createRecord('paper',
        id: paperId
        phase_ids: [phaseId]
        assignee_ids: [fakeUser.id]
        tasks: [
          id: messageTaskId
          type: "messageTask"
        ]
        journal_id: journalId
    )

    messageTask = paperPayload.createRecord 'messageTask',
      id: messageTaskId
      title: "Message Time"
      phase_id: phaseId
      paper_id: paperId
      lite_paper_id: paperId
      assignee_id: fakeUser.id
      participant_ids: [fakeUser.id]

    phase = paperPayload.createRecord 'phase',
      id: phaseId
      paper_id: paperId
      tasks: [
        id: messageTaskId
        type: "MessageTask"
      ]

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
