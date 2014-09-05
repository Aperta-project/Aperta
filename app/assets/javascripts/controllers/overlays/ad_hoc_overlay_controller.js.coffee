ETahi.AdHocOverlayController = ETahi.TaskController.extend
  newBlocks: []

  isNew: (block) ->
    @get('newBlocks').contains(block)

  replaceBlock: (block, otherBlock) ->
    blocks = @get('model.body')
    position = blocks.indexOf(block)
    if position isnt -1
      Ember.EnumerableUtils.replace(blocks, position, 1, [otherBlock])

  actions:
    addTextBlock: ->
      @get('newBlocks').pushObject([
          type: "text"
          value: ""
        ])

    addChecklist: ->
      @get('newBlocks').pushObject([
          type: "checkbox"
          value: ""
          answer: false
        ])

    addCheckboxItem: (block) ->
      block.pushObject
        type: "checkbox"
        value: ""
        answer: false

    saveBlock: (block) ->
      if @isNew(block)
        @get('model.body').pushObject(block)
        @get('newBlocks').removeObject(block)
      @send('saveModel')

    resetBlock: (block, snapshot) ->
      if @isNew(block)
        @get('newBlocks').removeObject(block)
      else
        @replaceBlock(block, snapshot)

    deleteBlock: (block) ->
      if @isNew(block)
        @get('newBlocks').removeObject(block)
      else
        @get('model.body').removeObject(block)
        @send('saveModel')

    deleteItem: (item, block) ->
      block.removeObject(item)
      if Ember.isEmpty(block)
        @send('deleteBlock', block)
      unless @isNew(block)
        @send('saveModel')
