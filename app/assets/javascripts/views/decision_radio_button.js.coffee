ETahi.DecisionRadioButton = ETahi.RadioButton.extend
  click: ->
    decision = @get('value')
    @get('controller').send('setDecisionTemplate', decision)

  checked: (->
    @get('value') == @get('selection')
  ).property()
