ETahi.FlowPaperView = Ember.View.extend
  templateName: 'flow_paper'
  tasks: ( ->
    @get('flow.tasks.content').filterBy('litePaper', @get('litePaper'))
  ).property('flow.tasks.@each.litePaper', 'litePaper')
