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
    @.$().tooltip()

`export default AddColumnComponent`

