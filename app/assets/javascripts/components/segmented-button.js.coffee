ETahi.SegmentedButtonComponent = Ember.Component.extend
  classNames: ['segmented-button']
  classNameBindings: ['active:segmented-button--active']

  text: null
  value: null
  selectedValue: null

  active: (->
    @get('value') == @get('selectedValue')
  ).property('selectedValue', 'value')

  click: ->
    @sendAction 'action', @get('value')
