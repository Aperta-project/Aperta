`import Ember from 'ember'`
`import Dragable from 'tahi/mixins/views/dragable'`

CardPreviewComponent = Ember.Component.extend Dragable,
  classNameBindings: [":card", "task.completed:card--completed", "classes"]

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
  ).property('commentLooks.[]', 'commentLooks.@each.taskId', 'task.id', 'commentLooks.@each.readAt')

  setupTooltip: (->
    # EMBERCLI TODO - Where does this come from?
    # @.$().find('.card-remove').tooltip()
  ).on('didInsertElement')

  dragStart: (e) ->
    if @get('canDragCard')
      ETahi.set('dragItem', @get('task'))

  actions:
    viewCard: (task) ->
      @sendAction('action', task)
    removeTask: (task) ->
      @sendAction('removeTask', task)
    promptDelete: (task) ->
      @sendAction('showDeleteConfirm', task)

`export default CardPreviewComponent`
