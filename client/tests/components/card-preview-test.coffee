`import Ember from 'ember'`
`import { test, moduleForComponent } from 'ember-qunit'`
`import FactoryGuy from 'ember-data-factory-guy'`
`import startApp from '../helpers/start-app'`
`import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper'`

App = null

moduleForComponent 'card-preview', 'Unit: components/card-preview',
  needs: ['helper:badge-count', "store:main"]

  setup: ->
    Ember.run ->
      App = startApp()
      TestHelper.setup()

  teardown: ->
    Ember.run ->
      TestHelper.teardown()
      App.destroy()

test "#unreadCommentsCount returns unread comments count", ->
  task = FactoryGuy.make("task", "withUnreadComments")
  component = @subject(task: task)
  equal(component.get('unreadCommentsCount'), 2)

test "#unreadCommentsCount gets updated when commentLook is 'read'", ->
  task = FactoryGuy.make("task", "withUnreadComments")
  component = @subject(task: task)
  Ember.run ->
    task.get("commentLooks").removeAt(0,2)
    equal(component.get('unreadCommentsCount'), 0)
