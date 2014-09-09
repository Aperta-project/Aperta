ETahi.CardView = Em.View.extend(DragNDrop.Dragable, {
  templateName: 'card'
  classNames: ['card']
  classNameBindings: ['completed', 'isMessage']

  setupTooltip: (->
    @.$().find('.card-remove').tooltip()
  ).on('didInsertElement')

  completed: (->
    if @get('content.completed') then 'card--completed' else false
  ).property('content.completed')

  isMessage: (->
    if @get('content.isMessage') then 'card--message' else false
  ).property('content.isMessage')

  comments: Ember.computed.alias 'content.comments'

  myCommentLooks: (->
    store = @get('controller.store')
    store.all('commentLook').filter (look) =>
      look.get('comment.task') == @get('content') and look.get('user') == @get('controller').getCurrentUser()
  ).property('comments.commentLooks.@each.readAt')

  unreadCommentsCount: (->
    @get('myCommentLooks').filter((look) ->
      Em.isEmpty(look.get('readAt'))
    ).length
  ).property('myCommentLooks.@each.readAt')

  dragStart: (e) ->
    e.dataTransfer.setData('Text', 'TAHI!')
    ETahi.set('dragItem', @get('content'))
})
