`import Ember from 'ember'`
`import RadioButtonComponent from 'tahi/pods/components/radio-button/component'`

DecisionRadioButtonComponent = RadioButtonComponent.extend
  click: ->
    decision = @get('value')
    Ember.run.later(@, (->
      @sendAction('action', decision)
    ), 150)

  checked: (->
    @get('value') == @get('selection')
  ).property()

`export default DecisionRadioButtonComponent`
