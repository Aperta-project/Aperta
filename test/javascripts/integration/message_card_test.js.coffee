module 'Integration: MessageCards',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp(integration: true)

    messageTaskId = 1
    authorId = 19932347

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

    dashboard =
      users: [fakeUser.user]
      affiliations: []
      lite_papers: [litePaper]
      dashboards: [
        id: 1
        user_id: fakeUser.user.id
        paper_ids: [paperId]
      ]

    paperResponse =
      phases: [
        id: 40
        name: "Submission Data"
        position: 1
        paper_id: paperId
        tasks: [
          id: messageTaskId
          type: "MessageTask"
        ]
      ]
      tasks: [
        id: messageTaskId
        title: "Message Time"
        type: "MessageTask"
        completed: false
        body: null
        paper_title: "Foo"
        role: "author"
        phase_id: 40
        paper_id: paperId
        lite_paper_id: paperId
        assignee_ids: []
        assignee_id: fakeUser.user.id
        participant_ids: [fakeUser.user.id]
      ]
      lite_papers: [litePaper]
      users: [fakeUser.user]
      journals: [journal]
      paper: paper

    server.respondWith 'GET', "/dashboards", [
      200, {"Content-Type": "application/json"}, JSON.stringify dashboard
    ]
    server.respondWith 'GET', "/papers/#{paperId}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]

    server.respondWith 'PUT', /\/tasks\/\d+/, [
      204, {"Content-Type": "application/json"}, JSON.stringify {}
    ]

test 'Showing a message card', ->
  expect(1)
  visit '/papers/1/tasks/1'
  .then -> equal(find('.overlay-content h1').text(), "Message Time")
