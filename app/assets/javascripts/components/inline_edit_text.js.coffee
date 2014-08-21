ETahi.InlineEditTextComponent = Em.Component.extend
  editing: false
  isNew: false
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

    deleteBlock: ->
      @get('model.body').removeObject(@get('bodyPart'))

