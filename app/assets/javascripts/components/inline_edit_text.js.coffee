ETahi.InlineEditTextComponent = Em.Component.extend
  editing: false
  isNew: false

  hasContent: Em.computed.notEmpty('bodyPart.value')

  hasNoContent: Em.computed.not('hasContent')

  actions:
    toggleEdit: ->
      @sendAction('cancel', @get('bodyPart')) if @get('editing')
      @toggleProperty 'editing'

    save: ->
      if @get('hasContent')
        @sendAction('save', @get('bodyPart'))
        @toggleProperty 'editing'
