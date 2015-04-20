`import Ember from 'ember'`

CardPreviewComponent = Ember.Component.extend
  classNameBindings: [':card', 'task.completed:card--completed', 'classes']

  paper: null
  commentLooks: Ember.computed.oneWay('defaultCommentLooks')
  task: null
  canRemoveCard: false
  classes: ''

  defaultCommentLooks: []

  unreadCommentsCount: (->
    taskId = @get('task.id')
    @get('commentLooks').filter((look) ->
      look.get('taskId') == taskId && Ember.isEmpty(look.get('readAt'))
    ).get('length')
  ).property('commentLooks.[]', 'commentLooks.@each.taskId', 'task.id', 'commentLooks.@each.readAt')

  actions:
    viewCard: (task) ->
      @sendAction('action', task)
    promptDelete: (task) ->
      @sendAction('showDeleteConfirm', task)

`export default CardPreviewComponent`
