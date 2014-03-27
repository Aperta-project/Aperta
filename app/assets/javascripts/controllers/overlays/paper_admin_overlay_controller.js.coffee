ETahi.PaperAdminOverlayController = ETahi.TaskController.extend
  actions:
    save: ->
      @get('paper').save()
