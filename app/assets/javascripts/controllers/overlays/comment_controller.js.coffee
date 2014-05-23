ETahi.CommentController = Ember.ObjectController.extend
  wasDisplayed: false

  setUnread: (->
    if @get('display') and !@get('wasDisplayed')
      comment = @get('model')
      @set('unread', !comment.get('hasBeenRead'))
      @set('wasDisplayed', true)
      unless comment.get('hasBeenRead')
        comment.set('hasBeenRead', true)
        comment.save().then (comment) =>
          @get('parentController').send('commentRead', comment)
  ).observes('display').on('init')

  display: (->
    @get('parentController.shownComments').contains(@get('model'))
  ).property('parentController.shownComments')
