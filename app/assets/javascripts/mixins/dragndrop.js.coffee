DragNDrop = Ember.Namespace.create()
window.DragNDrop = DragNDrop

DragNDrop.cancel = (e) ->
  e.preventDefault()
  false

DragNDrop.draggingStarted = (dropTargetsSelector, currentDropTarget)->
  $(dropTargetsSelector).removeClass('current-drop-target').addClass('not-drop-target')
  $(currentDropTarget).removeClass('not-drop-target').addClass('current-drop-target')

DragNDrop.draggingStopped = (dropTargetsSelector)->
  $(dropTargetsSelector).removeClass('current-drop-target').removeClass('not-drop-target')

DragNDrop.Dragable = Ember.Mixin.create
  attributeBindings: 'draggable'
  draggable: 'true'
  dragStart: (e) -> throw new Error("Implement dragStart")

DragNDrop.Droppable = Ember.Mixin.create
  dragEnter: DragNDrop.cancel
  dragOver: DragNDrop.cancel
  drop: (e) -> throw new Error("Implement drop")
