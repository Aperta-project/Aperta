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

test 'A message card with more than 5 comments has the show all comments button', ->
  expect(2)
  ef = ETahi.Factory
  r = _.range(10)
  comments = _.map(r, (n) ->
   ef.createRecord('Comment',
    commenter_id: fakeUser.id
    message_task_id: 1
    body: "My comment-#{n}"
    created_at: new Date().toISOString()
  ))

  [paper, task, records...] = createPaperWithOneTask('MessageTask'
    id: 1
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
  andThen ->
    ok(find('.load-all-comments').length == 1)
    equal(find('.message-comment').length, 5, 'Only 5 messages displayed')

test 'A message card with less than 5 comments doesnt have the show all comments button', ->
  expect(2)
  ef = ETahi.Factory
  r = _.range(3)
  comments = _.map(r, (n) ->
   ef.createRecord('Comment',
    commenter_id: fakeUser.id
    message_task_id: 1
    body: "My comment-#{n}"
    created_at: new Date().toISOString()
  ))

  [paper, task, records...] = createPaperWithOneTask('MessageTask'
    id: 1
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
  andThen ->
    ok(find('.load-all-comments').length == 0)
    equal(find('.message-comment').length, 3, 'All messages displayed')

test 'A message card with a commentLook shows up as unread and updates its commentLook', ->
  expect(2)
  ef = ETahi.Factory

  comment = ef.createRecord('Comment',
    commenter_id: fakeUser.id
    message_task_id: 1
    body: "Unread comment"
    created_at: new Date().toISOString()
  )
  commentLook = ef.createRecord('CommentLook', id: 1)
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

  server.respondWith 'PUT', /\/comment_looks\/\d+/, [
    204, {"Content-Type": "application/json"}, JSON.stringify {}
  ]

  visit("/papers/#{paper.id}/tasks/#{task.id}")
  andThen ->
    ok(_.findWhere(server.requests, {method: "PUT", url: "/comment_looks/1"}))
    equal(find('.message-comment.unread .comment-body').text(), "Unread comment")

test 'Showing all comments shows them.', ->
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
    id: 1
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
  click(".load-all-comments")
  andThen ->
    equal(find('.message-comment').length, 10, 'All messages displayed')

test 'Unread comments stay unread when showing all comments', ->
  expect(2)
  ef = ETahi.Factory
  r = _.range(10)
  comments = _.map(r, (n) ->
   ef.createRecord('Comment',
    commenter_id: fakeUser.id
    message_task_id: 1
    body: "My comment-#{n}"
    created_at: new Date().toISOString()
  ))

  #make the most recent comment unread
  recentComment = _.last(comments)
  recentComment.body = "Unread comment"

  commentLook = ef.createRecord('CommentLook', id: 1)
  ef.setForeignKey(recentComment, commentLook, {inverse: 'comment'})

  [paper, task, records...] = createPaperWithOneTask('MessageTask'
    id: 1
    title: "Message Time"
    participant_ids: [fakeUser.id]
    comment_ids: _.pluck(comments, 'id')
  )

  ef = ETahi.Factory
  paperPayload = ef.createPayload('paper')
  paperPayload.addRecords(records.concat(paper, task, fakeUser, comments, commentLook))

  server.respondWith 'GET', "/papers/#{paper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperPayload.toJSON()
  ]

  server.respondWith 'PUT', /\/comment_looks\/\d+/, [
    204, {"Content-Type": "application/json"}, JSON.stringify {}
  ]

  visit("/papers/#{paper.id}/tasks/#{task.id}")
  click(".load-all-comments")
  andThen ->
    equal(find('.message-comment.unread .comment-body').text(), 'Unread comment')
    equal(find('.message-comment').length, 10, 'All messages displayed')
