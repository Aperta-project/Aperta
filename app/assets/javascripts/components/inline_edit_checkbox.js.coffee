ETahi.InlineEditCheckboxComponent = Em.Component.extend
  editing: false
  isNew: false
  snapshot: {}

  createSnapshot: (->
    @set('snapshot', Em.copy(@get('bodyPart'), true))
  ).observes('editing')

  hasContent: Em.computed.notEmpty('bodyPart.value')

  hasNoContent: Em.computed.not('hasContent')

  checked: ((key, value, oldValue) ->
    if arguments.length > 1
      #setter
      @set('bodyPart.answer', value)
    else
      #getter
      answer = @get('bodyPart.answer')
      answer == 'true' || answer == true
  ).property('bodyPart.answer')

  actions:
    toggleEdit: ->
      @sendAction('cancel', @get('bodyPart'), @get('snapshot')) if @get('editing')
      @toggleProperty 'editing'

    save: ->
      if @get('hasContent')
        @sendAction('save', @get('bodyPart'))
        @toggleProperty 'editing'

    deleteItem: ->
      @sendAction('delete', @get('bodyPart'))

    saveModel: ->
      @sendAction('saveModel')
