module 'Integration: MessageCards',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp(integration: true)

    journalId = 1
    journal = ETahi.Factory.create('journal', id: journalId)

    paperId = 1
    paper = ETahi.Factory.create('paper',
        id: paperId
        phase_ids: [40]
        assignee_ids: [fakeUser.user.id]
        tasks: [
          id: messageTaskId
          type: "messageTask"
        ]
        journal_id: journalId
    )

    litePaper = ETahi.Factory.createLitePaper(paper)

    messageTaskId = 1
    messageTask = ETahi.Factory.create 'messageTask',
      id: messageTaskId
      title: "Message Time"
      phase_id: 40
      paper_id: paperId
      lite_paper_id: paperId
      assignee_id: fakeUser.user.id
      participant_ids: [fakeUser.user.id]

    phase =
      id: 40
      name: "Submission Data"
      position: 1
      paper_id: paperId
      tasks: [
        id: messageTaskId
        type: "MessageTask"
      ]
    dashboard =
      users: [fakeUser.user]
      affiliations: []
      lite_papers: [litePaper]
      dashboards: [
        id: 1
        user_id: fakeUser.user.id
        paper_ids: [paperId]
      ]

    m = ETahi.Factory.addRecordToManifest({}, 'paper', paper, true)
    m = ETahi.Factory.addRecordToManifest(m, 'lite_paper', litePaper, false)
    m = ETahi.Factory.addRecordToManifest(m, 'task', messageTask, false)
    m = ETahi.Factory.addRecordToManifest(m, 'phase', phase, false)
    m = ETahi.Factory.addRecordToManifest(m, 'user', fakeUser.user, false)
    m = ETahi.Factory.addRecordToManifest(m, 'journal', journal, false)
    paperPayload = ETahi.Factory.manifestToPayload(m)
    paperResponse = paperPayload

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
    commenter_id: fakeUser.user.id
    message_task_id: 1
    created_at: new Date().toISOString()

  foo = pushData('comment', commentData)
  expect(1)
  visit('/papers/1/tasks/1')
  andThen -> equal(find('.overlay-content h1').text(), "Message Time")
