ETahi.PaperAdminOverlayController = ETahi.TaskController.extend
  actions:
    save: ->
      @get('model').save()
