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
  errorText: ""
  addAuthorsTask: (->
    this.get('tasks').findBy('type', 'AuthorsTask')
  ).property()

  body: ((key, value) ->
    if arguments.length > 1 && value != @get('defaultBody')
      @set('model.body', value)

    modelBody = @get('model.body')
    if Ember.isBlank(modelBody)
      @get('defaultBody')
    else
      modelBody
  ).property('model.body')

  defaultBody: 'Type your manuscript here'
