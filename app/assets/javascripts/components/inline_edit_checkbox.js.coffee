ETahi.InlineEditCheckboxComponent = Em.Component.extend
  editing: false
  isNew: false
  checked: true

  hasContent: (->
    !Em.isEmpty(@get('bodyPart.value'))
  ).property('bodyPart.value')

  hasNoContent: Em.computed.not('hasContent')

  checked: (->
    !Em.isEmpty(@get('bodyPart.answer'))
  ).observes('bodyPart.answer')

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
