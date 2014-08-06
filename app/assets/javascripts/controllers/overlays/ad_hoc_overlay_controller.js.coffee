ETahi.AdHocOverlayController = ETahi.TaskController.extend
  editTitle: false

  actions:
    toggleEditTitle: ->
      @toggleProperty('editTitle')
      return null

    save: ->
      @get('model').save().then =>
        @send('toggleEditTitle')

