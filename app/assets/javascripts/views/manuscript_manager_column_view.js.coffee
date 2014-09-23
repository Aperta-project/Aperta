ETahi.ManuscriptManagerColumnView = Em.View.extend DragNDrop.Droppable,
  classNames: ['column']

  nextPosition: (->
    @get('contentIndex') + 1
  ).property('contentIndex')

  dragOver: (e) ->
    DragNDrop.draggingStarted('.column', @.$())
    DragNDrop.cancel(e)

  dragEnd: (e) ->
    DragNDrop.draggingStopped('.column')

  drop: (e) ->
    DragNDrop.draggingStopped('.column')
    @get('controller').send('changeTaskPhase', ETahi.get('dragItem'), @get('content'))
    e.preventDefault()
    false
