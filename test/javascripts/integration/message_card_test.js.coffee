setupMessagePayload = (messageTaskId) ->

createPaperWithOneTask = (taskType, taskAttrs) ->
  ef = ETahi.Factory
  journal = ef.createRecord('journal', id: 1)
  paper = ef.createRecord('paper', journal_id: journal.id)
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

test 'Showing a message card will work', ->
  expect(1)
  [paper, task, records...] = createPaperWithOneTask('messageTask'
    title: "Message Time"
    participant_ids: [fakeUser.id]
  )
  ef = ETahi.Factory
  paperPayload = ef.createPayload('paper')
  paperPayload.addRecords(records.concat(paper, task, fakeUser))

  server.respondWith 'GET', "/papers/#{paper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperPayload.toJSON()
  ]

  visit "/papers/#{paper.id}/tasks/#{task.id}"
  .then -> equal(find('.overlay-content h1').text(), "Message Time")

test 'A message card with a comment works', ->
  expect(1)
  ef = ETahi.Factory
  comment = ef.createRecord('comment',
    commenter_id: fakeUser.id
    message_task_id: 1
    body: "My comment"
  )
  [paper, task, records...] = createPaperWithOneTask('messageTask'
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

  expect(1)
  visit("/papers/#{paper.id}/tasks/#{task.id}")
  andThen -> equal(find('.message-comments .comment-body').text(), "My comment")
