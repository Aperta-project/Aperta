ETahi.AuthorGroupDropTargetView = Ember.View.extend DragNDrop.Droppable,
  tagName: 'div'
  classNames: ['author-drop-target']

  dragOver: (e) ->
    DragNDrop.draggingStarted('.author-drop-target', @.$())
    DragNDrop.cancel(e)

  dragEnd: (e) ->
    DragNDrop.draggingStopped('.author-drop-target')

  drop: (e) ->
    DragNDrop.draggingStopped('.author-drop-target')
    e.preventDefault()
    @get('controller').send('changeTaskPhase', ETahi.get('dragItem'), @get('content'))
    ETahi.set('dragItem', null)
    false
