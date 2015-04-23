`import Ember from 'ember'`
`import DocumentDownload from 'tahi/services/document-download'`

BasePaperController = Ember.Controller.extend
  needs: ['application', 'paper']

  currentUser: Ember.computed.alias 'controllers.application.currentUser'
  isAdmin: Ember.computed.alias 'controllers.application.isAdmin'
  supportedDownloadFormats: Ember.computed.alias('controllers.paper.supportedDownloadFormats')

  downloadLink: ( ->
    "/papers/#{@get('model.id')}/download"
  ).property('model.id')

  paper: Ember.computed.alias('model')

  logoUrl: (->
    logoUrl = @get('model.journal.logoUrl')
    if /default-journal-logo/.test logoUrl
      false
    else
      logoUrl
  ).property('model.journal.logoUrl')

  taskSorting: ['phase.position', 'position']

  authorTasks: Ember.computed.filterBy('model.tasks', 'role', 'author')

  canViewManuscriptManager: false

  assignedTasks: (->
    assignedTasks = @get('model.tasks').filter (task) =>
      task.get('participations').mapBy('user').contains(@currentUser)

    authorTasks   = @get('authorTasks')
    assignedTasks.filter (t)-> !authorTasks.contains(t)
  ).property('model.tasks.@each')

  sortedAuthorTasks: Ember.computed.sort('authorTasks', 'taskSorting')

  sortedAssignedTasks: Ember.computed.sort('assignedTasks', 'taskSorting')

  sortedEditorTasks: Ember.computed.sort('editorTasks', 'taskSorting')

  editorTasks: (->
    if @get('model.editors').contains(@get('currentUser'))
      @get('model.tasks').filterBy('role', 'reviewer')
  ).property('tasks.@each.role')

  sidebarIsEmpty: (->
    Ember.isEmpty(@get('assignedTasks')) && Ember.isEmpty(@get('editorTasks')) && Ember.isEmpty(@get('authorTasks'))
  ).property('assignedTasks.@each', 'editorTasks.@each', 'authorTasks.@each')

  actions:
    export: (downloadType) ->
      DocumentDownload.initiate(@get('model.id'), downloadType.format)

`export default BasePaperController`
