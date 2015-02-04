`import Ember from 'ember'`

TaskCommentComponent = Ember.Component.extend
  tagName: 'li'
  classNameBindings: [':message-comment', 'unread']

  unread: false
  commenter: Ember.computed.alias 'comment.commenter'
  createdAt: Ember.computed.alias 'comment.createdAt'
  body: Ember.computed.alias 'comment.body'
  highlightedBody: (->
    body = @get('comment.body')
    mentions = @get('comment.entities.user_mentions')
    @highlightBody(body, mentions)
  ).property('body')

  setUnreadState: ( ->
    Ember.run =>
      c = @get('comment')
      user = @get('currentUser')
      if c.isUnreadBy(user)
        @set('unread', true)
        c.markReadBy(user)
      else
        @set('unread', false)
  ).on('init')

  highlightBody: (body, mentions) ->
    if !mentions then return body
    mentionStrings = []
    for mention in mentions
      first = mention.indices[0]
      last = mention.indices[1]
      mentionString = body.slice(first, last)
      mentionStrings.push mentionString

    for mention in mentionStrings
      regex = new RegExp("(#{mention})")
      body = body.replace(regex, '<strong>$1</strong>')
    body

`export default TaskCommentComponent`
