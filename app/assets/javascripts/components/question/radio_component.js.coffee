ETahi.QuestionRadioComponent = ETahi.QuestionComponent.extend
  layoutName: 'components/question/radio_component'

  selectedYes: (->
    answer = @get('model.answer')
    answer == 'Yes'
  ).property('model.answer')
