ETahi.CommentBoardComponent = Ember.Component.extend
  commentBody: ""
  commentsToShow: 5
  showingAllComments: false
  commentSort: ['createdAt:desc']
  sortedComments: Ember.computed.sort('comments', 'commentSort')

  setUnreadStates: ( ->
    Ember.run =>
      shownComments = @get('shownComments')
      shownComments.forEach (c) =>
        if c.isUnread()
          c.set('unread', true)
          c.markRead()
  ).observes('shownComments.@each').on('init')

  shownComments: (->
    commentsLength =  @get('sortedComments.length')
    comments = @get('sortedComments')
    if @get('showingAllComments') then comments else comments.slice(commentsLength - @get("commentsToShow"))
  ).property('sortedComments.length', 'comments.@each.commentLook', 'showingAllComments')

  showingAllComments: (->
    @get('comments.length') <= @get('commentsToShow')
  ).property('comments.length')

  omittedCommentsCount: (->
    @get('comments.length') - @get("commentsToShow")
  ).property('comments.length')

  actions:
    showAllComments: ->
      @set('shownComments', @get('sortedComments'))
      @set('showingAllComments', true)

    postComment: ->
      @sendAction('postComment', @get("commentBody"))
      @send('clearComment')

    clearComment: ->
      @set('commentBody', "")
