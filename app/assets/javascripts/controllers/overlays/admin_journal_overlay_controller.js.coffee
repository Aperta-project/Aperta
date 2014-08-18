ETahi.AdminJournalOverlayController = ETahi.TaskController.extend
  needs: ['journalIndex']
  overlayClass: 'overlay--fullscreen journal-edit-overlay'
  propertyName: ''

  actions:
    save: ->
      controller = @get('controllers.journalIndex')
      controller.set("#{@get('propertyName')}SaveStatus", 'Saved')
      controller.get('model').save()
      @send('closeAction')
