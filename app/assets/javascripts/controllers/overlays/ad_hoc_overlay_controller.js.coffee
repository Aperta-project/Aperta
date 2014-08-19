ETahi.AdHocOverlayController = ETahi.TaskController.extend
  newTextBlock: null
  actions:
    addTextBlock: ->
      @set 'newTextBlock',
        type: "text"
        value: ""
