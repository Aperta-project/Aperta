`import Ember from 'ember'`

AddColumnComponent = Ember.Component.extend
  tagName: 'span'
  classNameBindings: [':add-column', 'bonusClass']
  attributeBindings: ['toggle:data-toggle', 'placement:data-placement', 'title']
  toggle: 'tooltip'
  placement: 'auto right'
  title: 'Add Phase'

  click: ->
    @sendAction('action', @get('position'))
  didInsertElement: ->
    # EMBERCLI TODO - what is this plugin?
    # @.$().tooltip()

`export default AddColumnComponent`
