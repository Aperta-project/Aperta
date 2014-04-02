ETahi.FlowPaperView = Ember.View.extend
  templateName: 'flow'
  tasks: Ember.computed.intersect('flow.tasks.content', 'paper.allTasks')
