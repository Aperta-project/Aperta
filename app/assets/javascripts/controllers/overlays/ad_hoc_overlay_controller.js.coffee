ETahi.AdHocOverlayController = ETahi.TaskController.extend
  newBlocks: []

  isNew: (block) ->
    @get('newBlocks').contains(block)

  replaceBlock: (block, otherBlock) ->
    blocks = @get('model.body')
    position = blocks.indexOf(block)
    if position isnt -1
      Ember.EnumerableUtils.replace(blocks, position, 1, [otherBlock])

  _pruneEmptyItems: (block) ->
    block.reject (item) ->
      Em.isEmpty(item.value)

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

    saveBlock: (block) ->
      if @isNew(block)
        @get('model.body').pushObject(block)
        @get('newBlocks').removeObject(block)
      @replaceBlock(block, @_pruneEmptyItems(block))
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

    addCheckboxItem: (block) ->
      block.pushObject
        type: "checkbox"
        value: ""
        answer: false

    deleteItem: (item, block) ->
      block.removeObject(item)
      if Ember.isEmpty(block)
        @send('deleteBlock', block)
      unless @isNew(block)
        @send('saveModel')
