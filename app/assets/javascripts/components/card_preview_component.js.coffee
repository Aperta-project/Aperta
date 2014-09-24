ETahi.CardPreviewComponent = Ember.Component.extend DragNDrop.Dragable,
  classNameBindings: [":card", "task.completed:card--completed", "task.isMessage:card--message", "classes"]
  actions:
    viewCard: (task) ->
      @sendAction('action', task)
    removeTask: (task) ->
      @sendAction('removeTask', task)

  paper: null
  commentLooks: Ember.computed.oneWay('defaultCommentLooks')
  task: null
  canRemoveCard: false
  canDragCard: false
  classes: ""

  defaultCommentLooks: []

  unreadCommentsCount: (->
    taskId = @get('task.id')
    @get('commentLooks').filter((look) ->
      look.get('taskId') == taskId && Em.isEmpty(look.get('readAt'))
    ).get('length')
  ).property('commentLooks.[]', 'commentLooks.@each.taskId', 'task.id')

  setupTooltip: (->
    @.$().find('.card-remove').tooltip()
  ).on('didInsertElement')

  dragStart: (e) ->
    if @get('canDragCard')
      e.dataTransfer.setData('Text', 'TAHI!')
      ETahi.set('dragItem', @get('task'))
