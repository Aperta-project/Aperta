ETahi.PaperReviewerOverlayController = ETahi.TaskController.extend

  actions:
    save: ->
      @get('model.paper').save().then((->
        ), (->
        ))
