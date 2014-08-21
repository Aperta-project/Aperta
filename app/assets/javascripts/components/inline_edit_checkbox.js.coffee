ETahi.InlineEditCheckboxComponent = Em.Component.extend
  editing: false
  isNew: false

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
      @sendAction('cancel', @get('bodyPart')) if @get('editing')
      @toggleProperty 'editing'

    save: ->
      if @get('hasContent')
        @sendAction('save', @get('bodyPart'))
        @toggleProperty 'editing'

    deleteBlock: ->
      @get('model.body').removeObject(@get('bodyPart'))
      @get('model').save()

    saveModel: ->
      @sendAction('saveModel')
