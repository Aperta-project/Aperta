ETahi.AuthorDropTargetView = Ember.View.extend DragNDrop.Droppable,
  tagName: 'div'
  classNameBindings: [':author-drop-target', 'isEditable::hidden']

  isEditable: Ember.computed.alias('controller.isEditable')

  position: ( ->
    @get('index') + 1
  ).property('index')

  notAdjacent: (thisPosition, dragItemPosition) ->
    thisPosition <= (dragItemPosition - 1) || thisPosition > (dragItemPosition + 1)

  dragEnter: (e) ->
    if @notAdjacent(this.get('position'), ETahi.get('dragItem.position'))
      DragNDrop.draggingStarted('.author-drop-target', @.$())
      DragNDrop.cancel(e)

  dragLeave: (e) ->
    DragNDrop.draggingStopped('.author-drop-target')

  drop: (e) ->
    DragNDrop.draggingStopped('.author-drop-target')
    e.preventDefault()
    #dragItem will be the author.
    ETahi.set('dragItem', null)
    false
