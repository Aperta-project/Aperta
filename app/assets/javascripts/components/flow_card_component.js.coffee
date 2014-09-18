ETahi.FlowCardComponent = Ember.Component.extend
  classNameBindings: [":card", ":flow-card", "task.completed:card--completed", "task.isMessage:card--message"]
  actions:
    viewCard: (paper, task) ->
      @sendAction('action', paper, task)
