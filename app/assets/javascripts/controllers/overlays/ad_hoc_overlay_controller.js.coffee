ETahi.AdHocOverlayController = ETahi.TaskController.extend
  newTextBlock: null
  newCheckboxItem: null
  isText: (block) ->
    block.type == "text"

  actions:
    addTextBlock: ->
      @set "newTextBlock",
        type: "text"
        value: ""

    addCheckboxItem: ->
      @set "newCheckboxItem",
        type: "checkbox",
        value: ""
        answer: ""
