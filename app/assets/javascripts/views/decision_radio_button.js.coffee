ETahi.DecisionRadioButton = ETahi.RadioButton.extend
  click: ->
    decision = @get('value')
    Ember.run.later(@, (->
      @get('controller').send('setDecisionTemplate', decision)
    ), 150)

  checked: (->
    @get('value') == @get('selection')
  ).property()
