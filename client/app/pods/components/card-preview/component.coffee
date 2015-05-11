`import Ember from 'ember'`

CardPreviewComponent = Ember.Component.extend
  classNameBindings: [':card', 'task.completed:card--completed', 'classes']

  task: null
  canRemoveCard: false
  classes: ''

  unreadCommentsCount: (->
    # note: this is used for "task-templates", who do not have comment-looks
    (@get('task.commentLooks') || []).length
  ).property('task.commentLooks.@each')

  actions:
    viewCard: (task) ->
      @sendAction('action', task)
    promptDelete: (task) ->
      @sendAction('showDeleteConfirm', task)

`export default CardPreviewComponent`
