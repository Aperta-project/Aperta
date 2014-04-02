ETahi.FlowPaperView = Ember.View.extend
  templateName: 'flow_paper'
  tasks: Ember.computed.intersect('flow.tasks.content', 'paper.allTasks')
