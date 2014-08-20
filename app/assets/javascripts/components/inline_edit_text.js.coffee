ETahi.InlineEditTextComponent = Em.Component.extend
  editing: false
  isNew: false

  hasContent: (->
    !Em.isEmpty(@get('bodyPart.value'))
  ).property('bodyPart.value')

  hasNoContent: Em.computed.not('hasContent')

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
