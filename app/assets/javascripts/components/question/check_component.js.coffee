ETahi.QuestionCheckComponent = ETahi.QuestionComponent.extend
  layoutName: 'components/question/check_component'
  multipleAdditionalData: false
  displayContent: Em.computed.alias('checked')

  checked: ((key, value, oldValue) ->
    if arguments.length > 1
      #setter
      @set('model.answer', value)
    else
      #getter
      answer = @get('model.answer')
      answer == 'true' || answer == true
  ).property('model.answer')

  actions:
    additionalDataAction: ()->
      @get('additionalData').pushObject({})
