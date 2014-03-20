ETahi.DeclarationTaskController = ETahi.TaskController.extend
  actions:
    save: ->
      debugger
      @get('declaration').save()
