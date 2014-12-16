ETahi.DecisionRadioButton = ETahi.RadioButton.extend
  click: ->
    @get('controller').send('setDecisionTemplate', @get('value'))
