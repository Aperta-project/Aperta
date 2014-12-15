ETahi.FlowTaskGroupComponent = Ember.Component.extend
  tagName: 'li'

  actions:
    viewCard: (task) ->
      @sendAction('viewCard', task)
