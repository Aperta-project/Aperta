ETahi.PaperEditController = Ember.ObjectController.extend
  needs: ['application']

  submissionPhase: ( ->
    @get('phases').findBy('name', 'Submission Data')
  ).property('phases.@each.name')

  downloadLink: ( ->
    "/papers/#{@get('id')}/download"
  ).property()

  authorTasks: Ember.computed.filterBy('submissionPhase.tasks', 'role', 'author')

  assignedTasks: (->
    assignedTasks = @get('allTasks').filterBy 'assignee', @get('controllers.application.currentUser')
    _.difference assignedTasks, @get('authorTasks')
  ).property('allTasks.@each.assignee')

  reviewerTasks: Ember.computed.filterBy('allTasks', 'role', 'reviewer')

  authorNames: ( ->
    authors = @get('authors').map (author) ->
      [author.first_name, author.last_name].join(' ')
    authors.join(', ')
  ).property('authors.@each')
