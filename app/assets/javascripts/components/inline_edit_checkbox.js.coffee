ETahi.InlineEditCheckboxComponent = Em.Component.extend
  editing: false
  isNew: false

  hasContent: (->
    !Em.isEmpty(@get('bodyPart.value'))
  ).property('bodyPart.value')

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
      if @get('isNew')
        @sendAction('cancel', @get('bodyPart'))
      else
        @get('model').rollback()
      @toggleProperty 'editing'

    save: ->
      if @get('hasContent')
        if @get('isNew')
          @get('model.body').pushObject(@get('bodyPart'))
          @sendAction('cancel', @get('bodyPart'))
        @get('model').save()
        @toggleProperty 'editing'

    saveModel: ->
      @get('model').save()
