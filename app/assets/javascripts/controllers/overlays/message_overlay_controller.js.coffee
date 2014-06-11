ETahi.MessageOverlayController = ETahi.TaskController.extend ETahi.ControllerParticipants,
  newCommentBody: ""

  overlayClass: 'message-overlay'

  _clearNewMessage: ->
    @set('newCommentBody', "")

  commentSort: ['createdAt:asc']
  sortedComments: Ember.computed.sort('model.comments', 'commentSort')

  unreadComments: []

  shownComments: (->
    commentsLength =  @get('sortedComments.length')
    comments = @get('sortedComments')
    if @get('showAllComments') then comments else comments.slice(commentsLength - 5)
  ).property('model.comments.length', 'model.comments.@each.commentLook', 'showAllComments')


  setUnreadStates: ( ->
    return if @get('isClosed')
    Ember.run =>
      unreadComments = @get('unreadComments')
      shownComments = @get('shownComments')
      shownComments.forEach (c) ->
        if commentLook = c.get('commentLook')
          if !unreadComments.contains(c.get('id'))
            unreadComments.addObject(c.get('id'))
            commentLook.set('readAt', new Date())
            commentLook.save()

      unreadComments.forEach (id) ->
        if comment = shownComments.findBy('id', id)
          comment.set('unread', true)
  ).observes('shownComments.@each').on('init')

  showAllComments: (->
    @get('sortedComments.length') < 6
  ).property('sortedComments.length')

  setupTooltips: (->
    Ember.run.schedule 'afterRender', ->
      $('.user-thumbnail').tooltip(placement: 'bottom')
  ).observes('model.participants.length')

  omittedCommentsCount: (->
    @get('sortedComments.length') - 5
  ).property('model.comments.length')

  actions:
    clearMessageContent: ->
      @_clearNewMessage()

    showAllComments: ->
      @set('shownComments', @get('sortedComments'))
      @set('showAllComments', true)

    closeOverlay: ->
      @set('isClosed', true)
      true

    postComment: ->
      body = @get('newCommentBody')
      return unless body
      commenter = @getCurrentUser()
      commentFields =
        commenter: commenter
        messageTask: @get('model')
        body: body
        createdAt: new Date()
      newComment = @store.createRecord('comment', commentFields)
      newComment.save()
        .then(@_clearNewMessage.bind(@), newComment.deleteRecord)
        .then(@send('saveNewParticipant', commenter))
