ETahi.QuestionCheckComponent = ETahi.QuestionComponent.extend
  layoutName: 'components/question/check_component'
  multipleAdditionalData: false

  checked: (->
    answer = @get('model.answer')
    answer == 'true' || answer == true
  ).property('model.answer')

  actions:
    additionalDataAction: ()->
      @get('additionalData').pushObject({})

