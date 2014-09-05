ETahi.InlineEditBodyPartComponent = Em.Component.extend
  editing: false
  snapshot: []
  confirmDelete: false

  createSnapshot: (->
    @set('snapshot', Em.copy(@get('block'), true))
  ).observes('editing')

  hasContent: (->
    @get('block').any(@_isEmpty)
  ).property('block.@each.value')

  hasNoContent: Em.computed.not('hasContent')

  bodyPartType: (->
    @get('block.firstObject.type')
  ).property('block.@each.type')

  _isEmpty: (item) ->
    item && !Ember.isEmpty(item.value)

  actions:
    toggleEdit: ->
      @sendAction('cancel', @get('block'), @get('snapshot')) if @get('editing')
      @toggleProperty 'editing'

    deleteBlock: ->
      @sendAction('delete', @get('block'))

    save: ->
      if @get('hasContent')
        @sendAction('save', @get('block'))
        @toggleProperty 'editing'

    confirmDeletion: ->
      @set('confirmDelete', true)

    cancelDestroy: ->
      @set('confirmDelete', false)

    addItem: ->
      @sendAction('addItem', @get('block'))
