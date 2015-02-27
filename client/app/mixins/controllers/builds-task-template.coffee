`import Ember from 'ember'`

BuildsTaskTemplate = Ember.Mixin.create
  newBlocks: []
  blocks: null
  emailSentStates: null

  _init: (->
    @set('newBlocks', [])
  ).on('init')

  setEmailStates:( ->
    @set('emailSentStates', Ember.ArrayProxy.create(content: []))
  ).on('init')

  isNew: (block) ->
    @get('newBlocks').contains(block)

  replaceBlock: (block, otherBlock) ->
    blocks = @get('blocks')
    position = blocks.indexOf(block)
    if position isnt -1
      Ember.EnumerableUtils.replace(blocks, position, 1, [otherBlock])

  _pruneEmptyItems: (block) ->
    block.reject (item) ->
      Ember.isEmpty(item.value)

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

    addEmail: ->
      @get('newBlocks').pushObject([
          type: "email"
          subject: ""
          value: ""
          sent: ""
        ])

    saveBlock: (block) ->
      if @isNew(block)
        @get('blocks').pushObject(block)
        @get('newBlocks').removeObject(block)
      @replaceBlock(block, @_pruneEmptyItems(block))

    resetBlock: (block, snapshot) ->
      if @isNew(block)
        @get('newBlocks').removeObject(block)
      else
        @replaceBlock(block, snapshot)

    addCheckboxItem: (block) ->
      block.pushObject
        type: "checkbox"
        value: ""
        answer: false

    deleteItem: (item, block) ->
      block.removeObject(item)
      if Ember.isEmpty(block)
        @send('deleteBlock', block)

    deleteBlock: (block) ->
      if @isNew(block)
        @get('newBlocks').removeObject(block)
      else
        @get('blocks').removeObject(block)

`export default BuildsTaskTemplate`
