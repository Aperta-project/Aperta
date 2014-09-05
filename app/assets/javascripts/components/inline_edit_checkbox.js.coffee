ETahi.InlineEditCheckboxComponent = Em.Component.extend ETahi.AdhocInlineEditItem,
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
    saveModel: ->
      @sendAction('saveModel')

    deleteItem: ->
      @sendAction('delete', @get('bodyPart'), @get('parentView.block'))
