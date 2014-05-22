ETahi.CommentController = Ember.ObjectController.extend
  # unread: Ember.computed.not 'hasBeenRead'

  setUnread: ( ->
    @set('unread', !@get('hasBeenRead'))
  ).on('init')

  actions:
    updateReadAt: ->
      comment = @get('model')
      if @get('unread')
        comment.set('hasBeenRead', true)
        comment.save()
