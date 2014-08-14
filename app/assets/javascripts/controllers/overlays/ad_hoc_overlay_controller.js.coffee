ETahi.AdHocOverlayController = ETahi.TaskController.extend
  bodyParts: []
  actions:
    addTextBlock: ->
      @bodyParts.pushObject
        type: "text"
        value: ""
