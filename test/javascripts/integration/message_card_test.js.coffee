setupMessagePayload = (messageTaskId) ->

createPaperWithOneTask = (taskType, taskAttrs) ->
  ef = ETahi.Factory
  journal = ef.createRecord('Journal', id: 1)
  paper = ef.createRecord('Paper', journal_id: journal.id)
  litePaper = ef.createLitePaper(paper)
  phase = ef.createPhase(paper)
  task = ef.createTask(taskType, paper, phase, taskAttrs)

  [paper, task, journal, litePaper, phase]

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

test 'A message card with a comment works', ->
  expect(1)
  ef = ETahi.Factory
  comment = ef.createRecord('Comment',
    commenter_id: fakeUser.id
    message_task_id: 1
    body: "My comment"
  )
  [paper, task, records...] = createPaperWithOneTask('MessageTask'
    title: "Message Time"
    participant_ids: [fakeUser.id]
    comment_ids: [comment.id]
  )
  ef = ETahi.Factory
  paperPayload = ef.createPayload('paper')
  paperPayload.addRecords(records.concat(paper, task, fakeUser, comment))
  server.respondWith 'GET', "/papers/#{paper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperPayload.toJSON()
  ]

  visit("/papers/#{paper.id}/tasks/#{task.id}")
  andThen -> equal(find('.message-comments .comment-body').text(), "My comment")

test 'A message card with a commentLook shows up as unread', ->
  expect(1)
  ef = ETahi.Factory

  server.respondWith 'PUT', /\/comment_looks\/\d+/, [
    204, {"Content-Type": "application/json"}, JSON.stringify {}
  ]

  comment = ef.createRecord('Comment',
    commenter_id: fakeUser.id
    message_task_id: 1
    body: "Unread comment"
  )
  commentLook = ef.createRecord('CommentLook')
  ef.setForeignKey(comment, commentLook, {inverse: 'comment'})

  [paper, task, records...] = createPaperWithOneTask('MessageTask'
    title: "Message Time"
    participant_ids: [fakeUser.id]
    comment_ids: [comment.id]
  )
  ef = ETahi.Factory
  paperPayload = ef.createPayload('paper')
  paperPayload.addRecords(records.concat(paper, task, fakeUser, comment, commentLook))
  server.respondWith 'GET', "/papers/#{paper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperPayload.toJSON()
  ]

  visit("/papers/#{paper.id}/tasks/#{task.id}")
  andThen -> equal(find('.message-comment.unread .comment-body').text(), "Unread comment")

test 'A message card with more than 5 comments has the show all comments button', ->
  expect(1)
  ef = ETahi.Factory
  r = _.range(10)
  comments = _.map(r, (n) ->
   ef.createRecord('Comment',
    commenter_id: fakeUser.id
    message_task_id: 1
    body: "My comment-#{n}"
  ))

  [paper, task, records...] = createPaperWithOneTask('MessageTask'
    title: "Message Time"
    participant_ids: [fakeUser.id]
    comment_ids: _.pluck(comments, 'id')
  )

  ef = ETahi.Factory
  paperPayload = ef.createPayload('paper')
  paperPayload.addRecords(records.concat(paper, task, fakeUser, comments))
  server.respondWith 'GET', "/papers/#{paper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperPayload.toJSON()
  ]

  visit("/papers/#{paper.id}/tasks/#{task.id}")
  andThen -> ok(find('.load-all-comments').length == 1)
