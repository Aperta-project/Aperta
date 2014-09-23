ETahi.FlowCardComponent = Ember.Component.extend DragNDrop.Dragable,
  classNameBindings: [":card", "task.completed:card--completed", "task.isMessage:card--message", "classes"]
  actions:
    viewCard: (paper, task) ->
      @sendAction('action', paper, task)

  paper: null
  commentLooks: null
  task: null
  canRemoveCard: false
  canDragCard: false
  classes: ""

  unreadCommentsCount: (->
    @get('commentLooks').filterBy('taskId', @get('task.id')).get('length')
  ).property('commentLooks.[]', 'commentLooks.@each.taskId', 'task.id')

  setupTooltip: (->
    @.$().find('.card-remove').tooltip()
  ).on('didInsertElement')

  dragStart: (e) ->
    if @get('canDragCard')
      e.dataTransfer.setData('Text', 'TAHI!')
      ETahi.set('dragItem', @get('task'))
