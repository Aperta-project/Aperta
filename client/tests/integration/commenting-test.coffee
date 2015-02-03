`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import { test } from 'ember-qunit'`
`import { paperWithTask } from '../helpers/setups'`
`import setupMockServer from '../helpers/mock-server'`
`import Factory from '../helpers/factory'`

app = null
server = null
currentUserId = null
# EMBERCLI TODO - the following window.currentUser.user is mega hack due to incompatibility
# with existing factory-esque payload creation
fakeUser = null

module 'Integration: Commenting',
  teardown: ->
    server.restore()
    Ember.run(app, app.destroy)

  setup: ->
    app = startApp()
    server = setupMockServer()
    currentUserId = getCurrentUser().get('id')
    fakeUser = window.currentUser.user

    dashboard =
      dashboards: [
        id: 1
        user_id: currentUserId
        lite_paper_ids: [1]
      ]

    collaborators = [
      id: "35"
      full_name: "Aaron Baker"
      info: "testroles2, collaborator"
    ]

    server.respondWith 'GET', "/dashboards", [
      200, {"Content-Type": "application/json"}, JSON.stringify dashboard
    ]

    server.respondWith 'PUT', /\/tasks\/\d+/, [
      204, {"Content-Type": "application/json"}, JSON.stringify {}
    ]

test 'A card with more than 5 comments has the show all comments button', ->
  expect(2)

  comments = _.map(_.range(10), (n) ->
    Factory.createRecord('Comment',
      commenter_id: currentUserId
      task: {type: 'Task', id: 1}
      body: "My comment-#{n}"
      created_at: new Date().toISOString()
    ))

  [paper, task, records...] = paperWithTask('Task'
    id: 1
    title: "Commenting Time"
    participant_ids: [currentUserId]
    comment_ids: comments.mapBy('id')
  )

  paperPayload = Factory.createPayload('paper')
  paperPayload.addRecords(records.concat(paper, task, fakeUser, comments))

  server.respondWith 'GET', "/papers/#{paper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperPayload.toJSON()
  ]

  visit("/papers/#{paper.id}/tasks/#{task.id}")

  andThen ->
    ok(find('.load-all-comments').length == 1)
    equal(find('.message-comment').length, 5, 'Only 5 messages displayed')

test 'A card with less than 5 comments doesnt have the show all comments button', ->
  expect(2)

  comments = _.map(_.range(3), (n) ->
    Factory.createRecord('Comment',
      commenter_id: currentUserId
      task: {type: 'Task', id: 1}
      body: "My comment-#{n}"
      created_at: new Date().toISOString()
    ))

  [paper, task, records...] = paperWithTask('Task'
    id: 1
    title: "Commenting Time"
    participant_ids: [currentUserId]
    comment_ids: _.pluck(comments, 'id')
  )

  paperPayload = Factory.createPayload('paper')
  paperPayload.addRecords(records.concat(paper, task, fakeUser, comments))

  server.respondWith 'GET', "/papers/#{paper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperPayload.toJSON()
  ]

  visit("/papers/#{paper.id}/tasks/#{task.id}")
  andThen ->
    ok(find('.load-all-comments').length == 0)
    equal(find('.message-comment').length, 3, 'All messages displayed')

test 'A task with a commentLook shows up as unread and updates its commentLook', ->
  expect(2)
  commenter = Factory.createRecord 'User',
    id: 999
    full_name: "Confucius"
    username: "confucius"
    email: "confucius@example.com"

  comment = Factory.createRecord('Comment',
    commenter_id: commenter.id
    task: {type: 'Task', id: 1}
    body: "Unread comment"
    created_at: new Date().toISOString()
  )
  commentLook = Factory.createRecord('CommentLook', id: 1)
  Factory.setForeignKey(comment, commentLook, {inverse: 'comment'})
  Factory.setForeignKey(fakeUser, commentLook, {inverse: 'user'})
  comment.comment_look_ids = [commentLook.id]

  [paper, task, records...] = paperWithTask('Task'
    title: "Commenting Time"
    id: 1
    participant_ids: [commenter.id, currentUserId]
    comment_ids: [comment.id]
  )

  paperPayload = Factory.createPayload('paper')
  paperPayload.addRecords(records.concat(paper, task, fakeUser, commenter, comment, commentLook))
  console.log paperPayload.toJSON()
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

  comments = _.map(_.range(10), (n) ->
    Factory.createRecord('Comment',
      commenter_id: currentUserId
      task: {type: 'Task', id: 1}
      body: "My comment-#{n}"
    ))

  [paper, task, records...] = paperWithTask('Task'
    id: 1
    title: "Commenting Time"
    participant_ids: [currentUserId]
    comment_ids: _.pluck(comments, 'id')
  )

  paperPayload = Factory.createPayload('paper')
  paperPayload.addRecords(records.concat(paper, task, fakeUser, comments))
  server.respondWith 'GET', "/papers/#{paper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperPayload.toJSON()
  ]

  visit("/papers/#{paper.id}/tasks/#{task.id}")
  click(".load-all-comments")
  andThen ->
    equal(find('.message-comment').length, 10, 'All messages displayed')

test 'Unread comments do not stay unread when showing all comments if they were already shown', ->
  expect(3)
  commenter = Factory.createRecord 'User',
    id: 999
    full_name: "Confucius"
    username: "confucius"
    email: "confucius@example.com"

  comments = _.map(_.range(10), (n) ->
    Factory.createRecord('Comment',
      commenter_id: commenter.id
      task: {type: 'Task', id: 1}
      body: "My comment-#{n}"
      # These can't all be created at the exact same time
      created_at: new Date(Date.now() + n).toISOString()
    ))

  #make the most recent comment unread
  recentComment = _.last(comments)
  recentComment.body = "Unread comment"

  commentLook = Factory.createRecord('CommentLook', id: 1)
  Factory.setForeignKey(recentComment, commentLook, {inverse: 'comment'})
  Factory.setForeignKey(fakeUser, commentLook, {inverse: 'user'})
  recentComment.comment_look_ids = [commentLook.id]

  [paper, task, records...] = paperWithTask('Task'
    id: 1
    title: "Commenting Time"
    participant_ids: [commenter.id, currentUserId]
    comment_ids: _.pluck(comments, 'id')
  )

  paperPayload = Factory.createPayload('paper')
  paperPayload.addRecords(records.concat(paper, task, fakeUser, commenter, comments, commentLook))

  server.respondWith 'GET', "/papers/#{paper.id}", [
    200, {"Content-Type": "application/json"}, JSON.stringify paperPayload.toJSON()
  ]

  server.respondWith 'PUT', /\/comment_looks\/\d+/, [
    204, {"Content-Type": "application/json"}, JSON.stringify {}
  ]

  visit("/papers/#{paper.id}/tasks/#{task.id}")
  andThen ->
    equal(find('.message-comment.unread .comment-body').text(), 'Unread comment')
    click(".load-all-comments")
  andThen ->
    equal(find('.message-comment.unread').length, 0)
    equal(find('.message-comment').length, 10, 'All messages displayed')
