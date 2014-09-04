ETahi.InlineEditBodyPartComponent = Em.Component.extend
  editing: false
  snapshot: []
  confirmDelete: false

  createSnapshot: (->
    @set('snapshot', Em.copy(@get('block'), true))
  ).observes('editing')

  hasContent: true
  # hasContent: Em.computed.notEmpty('bodyPart.value')

  hasNoContent: Em.computed.not('hasContent')

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
