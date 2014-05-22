ETahi.CommentController = Ember.ObjectController.extend
  unread: (->
    @get('model.commentLook') isnt null
  ).property()

  actions:
    updateReadAt: ->
