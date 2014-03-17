ETahi.AddColumnComponent = Ember.Component.extend
  tagName: 'span'
  classNameBindings: [':add-column', 'bonusClass']
  attributeBindings: ['toggle:data-toggle', 'placement:data-placement', 'title']
  toggle: 'tooltip'
  placement: 'auto right'
  title: 'Add Phase'

  click: (e) ->
    @sendAction('action', @get('position'))
  didInsertElement: ->
    @.$().tooltip()
