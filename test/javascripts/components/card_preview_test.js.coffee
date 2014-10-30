moduleForComponent 'card-preview', 'Unit: components/card-preview',
  setup: ->
    setupApp()
    @task = Ember.Object.create id: 99
    @readCommentLook = Ember.Object.create taskId: 99, readAt: "2015-09-01"
    @unreadCommentLook = Ember.Object.create taskId: 99, readAt: null

    Ember.run =>
      @component = @subject()
      @component.setProperties(task: @task, commentLooks: [@unreadCommentLook, @readCommentLook])

test "#unreadCommentsCount returns unread comments count", ->
  equal @component.get('unreadCommentsCount'), 1

test "#unreadCommentsCount gets updated when commentLook is read", ->
  @unreadCommentLook.set('readAt', '2015-09-01')
  equal @component.get('unreadCommentsCount'), 0
