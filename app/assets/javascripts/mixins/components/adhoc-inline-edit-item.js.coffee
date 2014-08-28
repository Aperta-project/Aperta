ETahi.AdhocInlineEditItem = Em.Mixin.create
  editing: false
  isNew: false
  confirmDelete: false
  snapshot: {}

  createSnapshot: (->
    @set('snapshot', Em.copy(@get('bodyPart'), true))
  ).observes('editing')

  hasContent: Em.computed.notEmpty('bodyPart.value')

  hasNoContent: Em.computed.not('hasContent')

  actions:
    toggleEdit: ->
      @sendAction('cancel', @get('bodyPart'), @get('snapshot')) if @get('editing')
      @toggleProperty 'editing'

    save: ->
      if @get('hasContent')
        @sendAction('save', @get('bodyPart'))
        @toggleProperty 'editing'

    confirmDeletion: ->
      @set('confirmDelete', true)

    deleteItem: ->
      @sendAction('delete', @get('bodyPart'))

    cancelDestroy: ->
      @set('confirmDelete', false)
