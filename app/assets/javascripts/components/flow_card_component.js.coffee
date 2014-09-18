ETahi.FlowCardComponent = Ember.Component.extend
  classNameBindings: [":card", ":flow-card", "task.completed:card--completed", "task.isMessage:card--message"]
  actions:
    viewCard: (paper, task) ->
      @sendAction('action', paper, task)

  commentLooks: null
  task: null

  unreadCommentCount: (->
    @get('commentLooks').filterBy('taskId', @get('task.id')).get('length')
  ).property('commentLooks.[]', 'commentLooks.@each.taskId', 'task.id')
