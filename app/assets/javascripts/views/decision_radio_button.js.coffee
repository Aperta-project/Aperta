ETahi.DecisionRadioButton = ETahi.RadioButton.extend
  click: ->
    paper = @get('model')
    decision = @get('value')
    @get('controller').send('setDecisionTemplate', paper, decision)

  checked: (->
    @get('value') == @get('selection')
  ).property()
