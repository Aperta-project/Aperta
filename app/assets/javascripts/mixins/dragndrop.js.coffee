DragNDrop = Ember.Namespace.create()
window.DragNDrop = DragNDrop

DragNDrop.cancel = (e) ->
  e.preventDefault()
  false

DragNDrop.Dragable = Ember.Mixin.create(
  attributeBindings: 'draggable'
  draggable: 'true'
  dragStart: (e) ->
    dataTransfer = e.originalEvent.dataTransfer
    dataTransfer.setData 'Text', @get('task.id')
    return
)

DragNDrop.Droppable = Ember.Mixin.create(
  dragEnter: DragNDrop.cancel
  dragOver: DragNDrop.cancel
  drop: (e) ->
    modelID = e.originalEvent.dataTransfer.getData('Text')
    #Ember.View.views[viewId].destroy()
    e.preventDefault()
    false
)
