ETahi.DecisionRadioButton = ETahi.RadioButton.extend
  click: ->
    paper = @get('model')
    decision = @get('value')
    Ember.run.later(@, (->
      @get('controller').send('setDecisionTemplate', paper, decision)
    ), 150)

  checked: (->
    @get('value') == @get('selection')
  ).property()
