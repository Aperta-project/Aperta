ETahi.CommentBoardComponent = Ember.Component.extend
  commentBody: ""
  commentsToShow: 5
  showingAllComments: false
  commentSort: ['createdAt:asc']
  sortedComments: Ember.computed.sort('comments', 'commentSort')
  unreadComments: []

  setUnreadStates: ( ->
    Ember.run =>
      unreadComments = @get('unreadComments')
      shownComments = @get('shownComments')
      shownComments.forEach (c) ->
        if commentLook = c.get('commentLook')
          # if comment is unread, make it read
          if !unreadComments.contains(c.get('id'))
            unreadComments.addObject(c.get('id'))
            commentLook.set('readAt', new Date())
            commentLook.save()

      # show purple background for unread messages?
      unreadComments.forEach (id) ->
        if comment = shownComments.findBy('id', id)
          comment.set('unread', true)
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
    @get('comments.length') - 5
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
