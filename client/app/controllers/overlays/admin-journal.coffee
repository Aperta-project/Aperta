`import TaskController from 'tahi/pods/task/controller'`

AdminJournalOverlayController = TaskController.extend
  needs: ['admin/journal/index']
  overlayClass: 'overlay--fullscreen journal-edit-overlay'
  propertyName: ''

  actions:
    save: ->
      controller = @get('controllers.admin/journal/index')
      controller.set("#{@get('propertyName')}SaveStatus", 'Saved')
      controller.get('model').save()
      @send('closeAction')

`export default AdminJournalOverlayController`
