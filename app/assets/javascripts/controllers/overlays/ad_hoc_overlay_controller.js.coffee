ETahi.AdHocOverlayController = ETahi.TaskController.extend
  editTitle: false

  actions:
    toggleEditTitle: ->
      @get('model').rollback()
      @toggleProperty('editTitle')
      return null

    save: ->
      @get('model').save().then =>
        @send('toggleEditTitle')

