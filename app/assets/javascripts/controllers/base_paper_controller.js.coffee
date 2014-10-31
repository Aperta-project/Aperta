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

  assignedTasks: (->
    assignedTasks = @get('tasks').filter (task) =>
      task.get('participations').mapBy('participant').contains(@getCurrentUser())

    authorTasks   = @get('authorTasks')
    assignedTasks.filter (t)-> !authorTasks.contains(t)
  ).property('tasks.@each')

  editorTasks: (->
    if @get('model.editors').contains(@get('currentUser'))
      @get('tasks').filterBy('role', 'reviewer')
  ).property('tasks.@each.role')

  hasNoMetaDataTasks: (->
    Em.isEmpty(@get('assignedTasks')) && Em.isEmpty(@get('editorTasks')) && Em.isEmpty(@get('authorTasks'))
  ).property('assignedTasks.@each', 'editorTasks.@each', 'authorTasks.@each')
