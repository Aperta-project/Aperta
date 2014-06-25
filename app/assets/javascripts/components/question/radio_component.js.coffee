ETahi.QuestionRadioComponent = ETahi.QuestionComponent.extend
  layoutName: 'components/question/radio_component'
  displayContent: Em.computed.oneWay('selectedYes')

  selectedYes: (->
    @get('model.answer') == 'Yes'
  ).property('model.answer')

  selectedNo: (->
    @get('model.answer') == 'No'
  ).property('model.answer')
