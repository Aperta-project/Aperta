`import Ember from 'ember'`
`import DragNDrop from 'tahi/services/drag-n-drop'`

Droppable = Ember.Mixin.create
  dragEnter: DragNDrop.cancel
  dragOver: DragNDrop.cancel
  drop: (e) -> throw "Implement drop"

`export default Droppable`
