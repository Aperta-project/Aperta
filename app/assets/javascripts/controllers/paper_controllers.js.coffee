ETahi.PaperController = Ember.ObjectController.extend
  needs: ['application']

  downloadLink: ( ->
    "/papers/#{@get('id')}/download"
  ).property('id')

  authorTasks: Ember.computed.filterBy('tasks', 'role', 'author')

  assignedTasks: (->
    assignedTasks = @get('tasks').filterBy 'assignee', @get('controllers.application.currentUser')
    authorTasks   = @get('authorTasks')

    assignedTasks.filter (t)-> !authorTasks.contains(t)
  ).property('tasks.@each.assignee')

  reviewerTasks: Ember.computed.filterBy('tasks', 'role', 'reviewer')

  noAuthors: (->
    Em.isEmpty(@get('authors'))
  ).property('authors.[]')

  authorNames: ( ->
    authors = @get('authors').map (author) ->
      [author.first_name, author.last_name].join(' ')
    authors.join(', ') || 'Click here to add authors'
  ).property('authors.[]', 'authors.@each')

# These controllers have to be here for now since the load order
# gets messed up otherwise
ETahi.PaperIndexController = ETahi.PaperController.extend()
ETahi.PaperEditController = ETahi.PaperController.extend
  addAuthorsTask: (->
    this.get('tasks').findBy('type', 'AuthorsTask')
  ).property()
