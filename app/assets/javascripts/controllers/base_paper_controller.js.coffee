ETahi.BasePaperController = Ember.ObjectController.extend
  needs: ['application']

  currentUser: Ember.computed.alias 'controllers.application.currentUser'
  isAdmin: Ember.computed.alias 'controllers.application.isAdmin'

  downloadLink: ( ->
    "/papers/#{@get('id')}/download"
  ).property('id')

  logoUrl: (->
    logoUrl = @get('model.journal.logoUrl')
    if /default-journal-logo/.test logoUrl
      false
    else
      logoUrl
  ).property()

  authorTasks: Ember.computed.filterBy('tasks', 'role', 'author')

  canViewManuscriptManager: false

  showManuscriptManagerLink: (->
    Ember.$.ajax
      url: "/papers/#{@get('id')}/manuscript_manager"
      method: 'GET'
      headers:
        'Tahi-Authorization-Check': true
      success: (data) =>
        @set('canViewManuscriptManager', true)
      error: =>
        @set('canViewManuscriptManager', false)
  ).observes('model.id')

  assignedTasks: (->
    assignedTasks = @get('tasks').filterBy 'assignee', @get('currentUser')
    authorTasks   = @get('authorTasks')

    assignedTasks.filter (t)-> !authorTasks.contains(t)
  ).property('tasks.@each.assignee')

  reviewerTasks: Ember.computed.filterBy('tasks', 'role', 'reviewer')

  noAuthors: (->
    Em.isEmpty(@get('authors'))
  ).property('authors.[]')

  authorNames: ( ->
    authors = @get('authors').map (author) ->
      author.get('fullName')
    authors.join(', ') || 'Click here to add authors'
  ).property('authors.[]', 'authors.@each')

