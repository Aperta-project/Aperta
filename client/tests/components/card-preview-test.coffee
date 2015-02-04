`import Ember from 'ember'`
`import { test, moduleForComponent } from 'ember-qunit'`

moduleForComponent 'card-preview', 'Unit: components/card-preview',
  needs: ['helper:badge-count']

test "#unreadCommentsCount returns unread comments count", ->
  task = Ember.Object.create id: 99
  readCommentLook = Ember.Object.create taskId: 99, readAt: "2015-09-01"
  unreadCommentLook = Ember.Object.create taskId: 99, readAt: null

  component = @subject(task: task, commentLooks: [ unreadCommentLook, readCommentLook])

  equal(component.get('unreadCommentsCount'), 1)

test "#unreadCommentsCount gets updated when commentLook is read", ->
  task = Ember.Object.create id: 99
  readCommentLook = Ember.Object.create taskId: 99, readAt: "2015-09-01"
  unreadCommentLook = Ember.Object.create taskId: 99, readAt: null

  component = @subject(task: task, commentLooks: [ unreadCommentLook, readCommentLook])

  unreadCommentLook.set('readAt', '2015-09-01')

  equal(component.get('unreadCommentsCount'), 0)
