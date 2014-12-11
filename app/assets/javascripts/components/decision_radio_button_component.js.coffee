#= require components/radio_button_component
ETahi.DecisionRadioButtonComponent = ETahi.RadioButtonComponent.extend
  click: ->
    decision = @get('value')
    Ember.run.later(@, (->
      @sendAction('action', decision)
    ), 150)

  checked: (->
    @get('value') == @get('selection')
  ).property()
