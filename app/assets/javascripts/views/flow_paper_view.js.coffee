ETahi.FlowPaperView = Ember.View.extend
  templateName: 'flow_paper'
  tasks: ( ->
    @get('flow.tasks.content').filterBy('paper', @get('paper'))
  ).property('flow.tasks.@each.paper', 'paper')
