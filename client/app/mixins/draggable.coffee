`import Ember from 'ember'`

Draggable = Ember.Mixin.create
  attributeBindings: 'draggable'
  draggable: 'true'
  dragStart: (e) -> throw 'Implement dragStart'

  cancelDraggableEvent: (e) ->
    e.preventDefault()
    false

`export default Draggable`
