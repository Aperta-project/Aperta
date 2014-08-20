ETahi.AdHocOverlayController = ETahi.TaskController.extend
  newBlockItems: []
  isText: (block) ->
    block.type == "text"

  actions:
    addTextBlock: ->
      @get('newBlockItems').pushObject
        type: "text"
        value: ""

    addCheckboxItem: ->
      @get('newBlockItems').pushObject
        type: "checkbox",
        value: ""
        answer: ""

    removeBlockItem: (blockItem)->
      @get('newBlockItems').removeObject(blockItem)
