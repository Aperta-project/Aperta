ETahi.PaperEditController = Ember.ObjectController.extend

  submissionPhase: ( ->
    @get('phases').findBy('name', 'Submission Data')
  ).property('phases.@each.name')

  authorTasks: Ember.computed.filterBy('submissionPhase.tasks', 'role', 'author')

  reviewerTasks: Ember.computed.filterBy('allTasks', 'role', 'reviewer')

  assignedTasks: Ember.computed.setDiff('allTasks', 'authorTasks')


