setupMessagePayload = (messageTaskId) ->

module 'Integration: MessageCards',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp(integration: true)

    dashboard =
      dashboards: [
        id: 1
        user_id: fakeUser.id
        lite_paper_ids: [1]
      ]

    server.respondWith 'GET', "/dashboards", [
      200, {"Content-Type": "application/json"}, JSON.stringify dashboard
    ]
    server.respondWith 'PUT', /\/tasks\/\d+/, [
      204, {"Content-Type": "application/json"}, JSON.stringify {}
    ]

test 'Showing a message card will work', ->
  expect(1)
  ef = ETahi.Factory
  recordDefs =
    paper:
      assignee_ids: [fakeUser.id]
      phases: [
        tasks: [
          messageTask:
            id: 1
            title: "Message Time"
            participant_ids: [fakeUser.id]
        ]
      ]
  records = ef.createBasicPaper(recordDefs)
  paperPayload = ef.createPayload('paper')
  _.forEach(records, (record) -> paperPayload.addRecord(record))
  paperPayload.addRecord(fakeUser)

  {paper} = paperPayload.toJSON()
  server.respondWith 'GET', "/papers/#{paper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperPayload.toJSON()
  ]

  visit '/papers/1/tasks/1'
  .then -> equal(find('.overlay-content h1').text(), "Message Time")

test 'A message card with a comment works', ->
  expect(1)
  ef = ETahi.Factory
  comment = ef.createRecord('comment',
    commenter_id: fakeUser.id
    message_task_id: 1
    body: "My comment"
  )

  recordDefs =
    paper:
      assignee_ids: [fakeUser.id]
      phases: [
        tasks: [
          messageTask:
            id: 1
            title: "Message Time"
            participant_ids: [fakeUser.id]
            comment_ids: [comment.id]
        ]
      ]
  records = ef.createBasicPaper(recordDefs)
  paperPayload = ef.createPayload('paper')
  _.forEach(records, (record) -> paperPayload.addRecord(record))

  paperPayload.addRecord(fakeUser)
  paperPayload.addRecord(comment)

  {paper} = paperPayload.toJSON()

  server.respondWith 'GET', "/papers/#{paper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperPayload.toJSON()
  ]

  expect(1)
  visit("/papers/#{paper.id}/tasks/1")
  andThen -> equal(find('.message-comments .comment-body').text(), "My comment")

test 'A comment that has a commentLook shows up as unread', ->
  expect(1)
  ef = ETahi.Factory
  comment = ef.createRecord('comment',
    commenter_id: fakeUser.id
    message_task_id: 1
    body: "My comment"
  )

  recordDefs =
    paper:
      assignee_ids: [fakeUser.id]
      phases: [
        tasks: [
          messageTask:
            id: 1
            title: "Message Time"
            participant_ids: [fakeUser.id]
            comment_ids: [comment.id]
        ]
      ]
  records = ef.createBasicPaper(recordDefs)
  paperPayload = ef.createPayload('paper')
  _.forEach(records, (record) -> paperPayload.addRecord(record))

  paperPayload.addRecord(fakeUser)
  paperPayload.addRecord(comment)

  {paper} = paperPayload.toJSON()

  server.respondWith 'GET', "/papers/#{paper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperPayload.toJSON()
  ]

  expect(1)
  visit("/papers/#{paper.id}/tasks/1")
  andThen -> equal(find('.message-comments .comment-body').text(), "My comment")
