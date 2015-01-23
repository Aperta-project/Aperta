`import Ember from 'ember'`
`import DragNDrop from 'tahi/services/drag-n-drop'`

CardPreviewComponent = Ember.Component.extend DragNDrop.DraggableMixin,
  classNameBindings: [':card', 'task.completed:card--completed', 'classes']

  paper: null
  commentLooks: Ember.computed.oneWay('defaultCommentLooks')
  task: null
  canRemoveCard: false
  canDragCard: false
  classes: ''

  defaultCommentLooks: []

  unreadCommentsCount: (->
    taskId = @get('task.id')
    @get('commentLooks').filter((look) ->
      look.get('taskId') == taskId && Em.isEmpty(look.get('readAt'))
    ).get('length')
  ).property('commentLooks.[]', 'commentLooks.@each.taskId', 'task.id', 'commentLooks.@each.readAt')

  setupTooltip: (->
    # EMBERCLI TODO - Where does this come from?
    # @.$().find('.card-remove').tooltip()
  ).on('didInsertElement')

  dragDidStart: ((e) ->
    DragNDrop.dragItem = @get('task') if @get('canDragCard')
  ).on('dragStart')

  actions:
    viewCard: (task) ->
      @sendAction('action', task)
    removeTask: (task) ->
      @sendAction('removeTask', task)
    promptDelete: (task) ->
      @sendAction('showDeleteConfirm', task)

`export default CardPreviewComponent`
