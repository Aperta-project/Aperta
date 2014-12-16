ETahi.SegmentedButtonComponent = Ember.Component.extend
  classNames: ['segmented-button']
  classNameBindings: ['active:segmented-button--active']

  text: null
  value: null
  activeValue: null

  active: (->
    @get('value') == @get('activeValue')
  ).property('activeValue', 'value')

  click: ->
    @sendAction 'action', @get('value')
