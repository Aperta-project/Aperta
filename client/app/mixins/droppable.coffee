`import Ember from 'ember'`

Droppable = Ember.Mixin.create
  dragEnter: (e) ->
    @cancelDroppableEvent(e)

  dragOver: (e) ->
    @cancelDroppableEvent(e)

  drop: (e) -> throw 'Implement drop'

  cancelDroppableEvent: (e) ->
    e.preventDefault()
    false

`export default Droppable`
