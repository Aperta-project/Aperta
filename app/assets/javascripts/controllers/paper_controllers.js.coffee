ETahi.PaperController = Ember.ObjectController.extend
  needs: ['application']

  downloadLink: ( ->
    "/papers/#{@get('id')}/download"
  ).property()

  authorTasks: Ember.computed.filterBy('allTasks', 'role', 'author')

  assignedTasks: (->
    assignedTasks = @get('allTasks').filterBy 'assignee', @get('controllers.application.currentUser')
    authorTasks   = @get('authorTasks')

    assignedTasks.filter (t)-> !authorTasks.contains(t)
  ).property('allTasks.@each.assignee')

  reviewerTasks: Ember.computed.filterBy('allTasks', 'role', 'reviewer')

  authorNames: ( ->
    authors = @get('authors').map (author) ->
      [author.first_name, author.last_name].join(' ')
    authors.join(', ') || 'Click here to add authors'
  ).property('authors.@each')

# These controllers have to be here for now since the load order
# gets messed up otherwise
ETahi.PaperIndexController = ETahi.PaperController.extend()
ETahi.PaperEditController = ETahi.PaperController.extend
  addAuthorsTask: (->
    this.get('allTasks').findBy('type', 'AuthorsTask')
  ).property()
