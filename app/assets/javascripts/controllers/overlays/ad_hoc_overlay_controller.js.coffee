ETahi.AdHocOverlayController = ETahi.TaskController.extend
  newBlockItems: []
  isNew: (item) ->
    @get('newBlockItems').contains(item)

  actions:
    addTextBlock: ->
      @get('newBlockItems').pushObject
        type: "text"
        value: ""

    addCheckboxItem: ->
      @get('newBlockItems').pushObject
        type: "checkbox",
        value: ""
        answer: false

    saveBlockItem: (blockItem) ->
      if @isNew(blockItem)
        @get('model.body').pushObject(blockItem)
        @get('newBlockItems').removeObject(blockItem)
      @send('saveModel')

    resetBlockItem: (blockItem) ->
      if @isNew(blockItem)
        @get('newBlockItems').removeObject(blockItem)
      else
        @get('model').rollback()
