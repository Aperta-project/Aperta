ETahi.AdHocOverlayController = ETahi.TaskController.extend
  newBlockItems: []

  isNew: (item) ->
    @get('newBlockItems').contains(item)

  replaceBlockItem: (item, otherItem) ->
    items = @get('model.body')
    position = items.indexOf(item)
    if position isnt -1
      Ember.EnumerableUtils.replace(items, position, 1, [otherItem])

  actions:
    addTextBlock: ->
      @get('newBlockItems').pushObject([
          type: "text"
          value: ""
        ])

    addChecklist: ->
      @get('newBlockItems').pushObject([
          type: "checkbox"
          value: ""
          answer: false
        ])

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

    resetBlockItem: (blockItem, snapshot) ->
      if @isNew(blockItem)
        @get('newBlockItems').removeObject(blockItem)
      else
        @replaceBlockItem(blockItem, snapshot)

    deleteBlockItem: (blockItem) ->
      @get('model.body').removeObject(blockItem)
      @send('saveModel')
