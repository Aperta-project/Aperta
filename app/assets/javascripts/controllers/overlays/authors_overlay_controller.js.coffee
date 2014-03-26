ETahi.AuthorsOverlayController = ETahi.TaskController.extend
  showNewAuthorForm: false
  actions:
    toggleNewAuthorForm: ->
      @set("showNewAuthorForm", !@showNewAuthorForm)
      return
