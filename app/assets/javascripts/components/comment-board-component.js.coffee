ETahi.CommentBoardComponent = Ember.Component.extend
  comments: []
  commentBody: ""
  commentsToShow: 5
  showingAllComments: false

  setUnreadStates: ( ->
    Ember.run =>
      @get('shownComments').forEach (c) =>
        if c.get('isUnread')
          c.set('unread', true)
          c.markRead()
  ).observes('shownComments.@each').on('init')

  shownComments: (->
    comments = @get('comments').sortBy('createdAt').reverse()
    if @get('showingAllComments') then comments else comments.slice(0, @get("commentsToShow"))
  ).property('comments.@each.createdAt', 'showingAllComments')

  showingAllComments: (->
    @get('comments.length') <= @get('commentsToShow')
  ).property('comments.length')

  omittedCommentsCount: (->
    @get('comments.length') - @get("commentsToShow")
  ).property('comments.length')

  actions:
    showAllComments: ->
      @set('showingAllComments', true)

    postComment: ->
      @sendAction('postComment', @get("commentBody"))
      @send('clearComment')

    clearComment: ->
      @set('commentBody', "")
