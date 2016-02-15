`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import { test } from 'ember-qunit'`
`import FactoryGuy from 'ember-data-factory-guy'`
`import TestHelper from "ember-data-factory-guy/factory-guy-test-helper"`

App = null

module 'Integration: Commenting',
  afterEach: ->
    Ember.run(-> TestHelper.teardown() )
    Ember.run(App, App.destroy)

  beforeEach: ->
    App = startApp()
    TestHelper.setup(App)
    $.mockjax(url: "/api/admin/journals/authorization", status: 204)
    $.mockjax(url: "/api/user_flows/authorization", status: 204)
    $.mockjax(url: "/api/journals", status: 200, responseText: { journals: [] })

    TestHelper.handleFindAll('discussion-topic', 1)


test 'A card with more than 5 comments has the show all comments button', (assert) ->
  expect(3)

  paper = FactoryGuy.make("paper")
  comments = FactoryGuy.makeList("comment", 10)
  task = FactoryGuy.make("task", paper: paper, comments: comments)

  TestHelper.handleFind(paper)
  TestHelper.handleFind(task)

  visit("/papers/#{paper.get("id")}/tasks/#{task.get("id")}")

  andThen ->
    assert.ok(find('.load-all-comments').length == 1)
    assert.equal(find('.message-comment').length, 5, 'Only 5 messages displayed')

    click(".load-all-comments")

    andThen ->
      assert.equal(find('.message-comment').length, 10, 'All messages displayed')

test 'A card with less than 5 comments doesnt have the show all comments button', (assert) ->
  expect(3)

  paper = FactoryGuy.make("paper")
  comments = FactoryGuy.makeList("comment", 3)
  task = FactoryGuy.make("task", paper: paper, comments: comments)

  TestHelper.handleFind(paper)
  TestHelper.handleFind(task)

  visit("/papers/#{paper.get("id")}/tasks/#{task.get("id")}")

  andThen ->
    assert.ok(find('.load-all-comments').length == 0)
    assert.equal(find('.message-comment').length, 3, 'All messages displayed')
    assert.equal(find('.message-comment.unread').length, 0)

test 'A task with a commentLook shows up as unread and deletes its comment look', (assert) ->
  expect(4)

  paper = FactoryGuy.make("paper")
  comments = FactoryGuy.makeList("comment", 2, "unread")
  task = FactoryGuy.make("task", paper: paper, comments: comments)

  TestHelper.handleFind(paper)
  TestHelper.handleFind(task)

  andThen ->
    comments.forEach (comment) ->
      TestHelper.handleDelete("comment-look", comment.get("commentLook.id"))

    assert.ok(comments[0].get("commentLook") != null)
    assert.ok(comments[1].get("commentLook") != null)

    visit("/papers/#{paper.id}/tasks/#{task.id}")

    andThen ->
      assert.equal(comments[0].get("commentLook"), null)
      assert.equal(comments[1].get("commentLook"), null)
