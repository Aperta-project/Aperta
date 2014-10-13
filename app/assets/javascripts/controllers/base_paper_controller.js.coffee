ETahi.BasePaperController = Ember.ObjectController.extend
  needs: ['application']

  currentUser: Ember.computed.alias 'controllers.application.currentUser'
  isAdmin: Ember.computed.alias 'controllers.application.isAdmin'

  downloadLink: ( ->
    "/papers/#{@get('id')}/download"
  ).property('id')

  paper: Ember.computed.alias('model')

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

  toggleEditRoute: ( ->
    if @get('editable')
      @transitionToRoute('paper.edit', @get('model'))
    else
      @transitionToRoute('paper.index', @get('model'))
  ).observes('editable')

  assignedTasks: (->
    assignedTasks = @get('tasks').filterBy 'assignee', @get('currentUser')
    authorTasks   = @get('authorTasks')

    assignedTasks.filter (t)-> !authorTasks.contains(t)
  ).property('tasks.@each.assignee')

  editorTasks: (->
    if @get('model.editors').contains(@get('currentUser'))
      @get('tasks').filterBy('role', 'reviewer')
  ).property('tasks.@each.role')

  authorNames: ( ->
    authors = @get('authors').map (author) ->
      author.get('fullName')
    authors.join(', ') || 'Click here to add authors'
  ).property('authors.[]', 'authors.@each')

