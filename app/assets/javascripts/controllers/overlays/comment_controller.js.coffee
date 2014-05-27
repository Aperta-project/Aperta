ETahi.CommentController = Ember.ObjectController.extend
  wasDisplayed: false
  unread: true

  setUnread: (->
    Ember.run.schedule 'afterRender', =>
      if @get('isDisplayed') and !@get('wasDisplayed')
        @getUnreadStatus().then =>
          comment = @get('model')
          @set('wasDisplayed', true)
          unless comment.get('hasBeenRead')
            comment.set('hasBeenRead', true)
            comment.save().then (comment) =>
              @get('parentController').send('commentRead', comment)
  ).observes('isDisplayed').on('init')

  getUnreadStatus: ( ->
    Ember.$.getJSON("/activities/comments/#{@get('id')}/unread").then (data) =>
      @set('hasBeenRead', data)
      @set('unread', !data)
  )

  isDisplayed: (->
    @get('parentController.shownComments').contains(@get('model'))
  ).property('parentController.shownComments')
