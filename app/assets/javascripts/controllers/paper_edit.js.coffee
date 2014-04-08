ETahi.PaperEditController = Ember.ObjectController.extend
  submissionPhase: ( ->
    @get('phases').findBy('name', 'Submission Data')
  ).property('phases.@each.name')

  downloadLink: ( ->
    "/papers/#{@get('id')}/download"
  ).property()

  authorTasks: Ember.computed.filterBy('submissionPhase.tasks', 'role', 'author')

  reviewerTasks: Ember.computed.filterBy('allTasks', 'role', 'reviewer')

  assignedTasks: Ember.computed.setDiff('allTasks', 'authorTasks')

  authorNames: ( ->
    authors = @get('authors').map (author) ->
      [author.first_name, author.last_name].join(' ')
    authors.join(', ')
  ).property('authors.@each')
