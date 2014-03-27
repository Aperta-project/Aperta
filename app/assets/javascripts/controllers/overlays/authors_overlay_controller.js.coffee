ETahi.AuthorsOverlayController = ETahi.TaskController.extend
  newAuthor: {}
  showNewAuthorForm: false
  actions:
    toggleAuthorForm: ->
      @set("showNewAuthorForm", !@showNewAuthorForm)

    saveNewAuthor: ->
      @get('paper.authors').pushObject @newAuthor
      @get('paper').save()
      @set("newAuthor", {})
      @send('toggleAuthorForm')
