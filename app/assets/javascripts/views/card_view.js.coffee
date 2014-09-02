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

  unreadCommentsCount: (->
    @get('commentLooks').filter((comment)->
      !comment.get('readAt')
    ).length
  ).property('commentLooks')

  commentLooks: (->
    comments = @get('comments') || []
    comments.mapBy('commentLook').compact()
  ).property('comments.@each.commentLook')

  dragStart: (e) ->
    e.dataTransfer.setData('Text', 'TAHI!')
    ETahi.set('dragItem', @get('content'))
})
