`import Ember from 'ember'`
`import DocumentDownload from 'tahi/services/document-download'`

BasePaperController = Ember.Controller.extend
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
  ).property('model.journal.logoUrl')

  taskSorting: ['phase.position', 'position']

  authorTasks: Ember.computed.filterBy('tasks', 'role', 'author')

  canViewManuscriptManager: false

  assignedTasks: (->
    assignedTasks = @get('tasks').filter (task) =>
      task.get('participations').mapBy('user').contains(@currentUser)

    authorTasks   = @get('authorTasks')
    assignedTasks.filter (t)-> !authorTasks.contains(t)
  ).property('tasks.@each')

  sortedAuthorTasks: Ember.computed.sort('authorTasks', 'taskSorting')

  sortedAssignedTasks: Ember.computed.sort('assignedTasks', 'taskSorting')

  sortedEditorTasks: Ember.computed.sort('editorTasks', 'taskSorting')

  editorTasks: (->
    if @get('model.editors').contains(@get('currentUser'))
      @get('tasks').filterBy('role', 'reviewer')
  ).property('tasks.@each.role')

  isSidebarEmpty: (->
    Ember.isEmpty(@get('assignedTasks')) && Ember.isEmpty(@get('editorTasks')) && Ember.isEmpty(@get('authorTasks'))
  ).property('assignedTasks.@each', 'editorTasks.@each', 'authorTasks.@each')

  actions:
    export: (downloadType) ->
      DocumentDownload.initiate(@get('id'), downloadType.format)

`export default BasePaperController`
