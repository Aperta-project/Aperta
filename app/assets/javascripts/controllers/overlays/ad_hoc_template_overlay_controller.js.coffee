ETahi.AdHocTemplateOverlayController = Ember.ObjectController.extend
  newBlocks: []
  phaseTemplate: null

  isNew: (block) ->
    @get('newBlocks').contains(block)

  replaceBlock: (block, otherBlock) ->
    blocks = @get('template')
    position = blocks.indexOf(block)
    if position isnt -1
      Ember.EnumerableUtils.replace(blocks, position, 1, [otherBlock])

  _pruneEmptyItems: (block) ->
    block.reject (item) ->
      Em.isEmpty(item.value)

  actions:
    setTitle: (title) ->
      @set('title', title)

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
        @get('template').pushObject(block)
        @get('newBlocks').removeObject(block)
      @replaceBlock(block, @_pruneEmptyItems(block))

    resetBlock: (block, snapshot) ->
      if @isNew(block)
        @get('newBlocks').removeObject(block)
      else
        @replaceBlock(block, snapshot)

    deleteBlock: (block) ->
      if @isNew(block)
        @get('newBlocks').removeObject(block)
      else
        @get('template').removeObject(block)

    addCheckboxItem: (block) ->
      block.pushObject
        type: "checkbox"
        value: ""
        answer: false

    deleteItem: (item, block) ->
      block.removeObject(item)
      if Ember.isEmpty(block)
        @send('deleteBlock', block)

    closeAction: ->
      @get('model').save().then =>
        @send('addTaskAndClose', @get('phaseTemplate'), @get('model'))
