ETahi.MessageOverlayController = ETahi.TaskController.extend ETahi.ControllerParticipants,
  newCommentBody: ""

  overlayClass: 'message-overlay'

  _clearNewMessage: ->
    @set('newCommentBody', "")

  commentSort: ['createdAt:asc']
  sortedComments: Ember.computed.sort('model.comments', 'commentSort')

  commentCount: Ember.computed.alias('sortedComments.length')

  shownComments: (->
    commentsLength =  @get('commentCount')
    comments = @get('sortedComments')
    if @get('showAllComments') then comments else comments.slice(commentsLength - 5)
  ).property('sortedComments', 'showAllComments')

  showAllComments: (->
    @get('commentCount') < 6
  ).property('commentCount')

  setupTooltips: (->
    Ember.run.later ->
      $('.user-thumbnail').tooltip(placement: 'bottom')
  ).observes('model.participants.length')

  omittedCommentsCount: (->
    @get('commentCount') - 5
  ).property('commentCount')

  actions:
    clearMessageContent: ->
      @_clearNewMessage()

    commentRead: ->
      @get('model').decrementProperty('unreadCommentsCount')

    showAllComments: ->
      @set('showAllComments', true)

    postComment: ->
      body = @get('newCommentBody')
      return unless body
      commenter = @getCurrentUser()
      commentFields =
        commenter: commenter
        messageTask: @get('model')
        body: body
        createdAt: new Date()
        hasBeenRead: true
      newComment = @store.createRecord('comment', commentFields)
      newComment.save()
        .then(@_clearNewMessage.bind(@), newComment.deleteRecord)
        .then(@send('saveNewParticipant', commenter))
