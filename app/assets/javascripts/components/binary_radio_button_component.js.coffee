ETahi.BinaryRadioButtonComponent = Ember.Component.extend
  selection: null
  index: null

  yesValue: true
  noValue: false

  yesLabel: 'Yes'
  noLabel: 'No'

  yesChecked: (->
    @get('yesValue') == @get('selection')
  ).property('selection', 'yesValue')

  noChecked: (->
    @get('noValue') == @get('selection')
  ).property('selection', 'noValue')

  actions:
    selectYes: ->
      @set('selection', @get('yesValue'))
      @sendAction("yesAction")
    selectNo: ->
      @set('selection', @get('noValue'))
      @sendAction("noAction")
