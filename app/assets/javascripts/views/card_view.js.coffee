ETahi.CardView = Em.View.extend(DragNDrop.Dragable, {
  templateName: 'card'
  classNames: ['card']
  classNameBindings: ['completed', 'isMessage']

  task: Em.computed.alias 'content'

  commentLooks: Em.computed.oneWay 'defaultCommentLooks'
  defaultCommentLooks: []

  setupTooltip: (->
    @.$().find('.card-remove').tooltip()
  ).on('didInsertElement')

  setCommentLooks: (->
    @set('commentLooks', @get('controller.store').all('commentLook'))
  ).on('didInsertElement')

  completed: (->
    if @get('content.completed') then 'card--completed' else false
  ).property('content.completed')

  isMessage: (->
    if @get('content.isMessage') then 'card--message' else false
  ).property('content.isMessage')

  myCommentLooks: (->
    @get('commentLooks').filterBy('taskId', @get('task.id'))
  ).property('commentLooks.[]', 'commentLooks.@each.taskId')

  unreadCommentsCount: (->
    @get('myCommentLooks').filter((look) ->
      Em.isEmpty(look.get('readAt'))
    ).length
  ).property('myCommentLooks.@each.readAt')

  dragStart: (e) ->
    e.dataTransfer.setData('Text', 'TAHI!')
    ETahi.set('dragItem', @get('content'))
})
