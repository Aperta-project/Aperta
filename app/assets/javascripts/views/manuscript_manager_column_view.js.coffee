ETahi.ManuscriptManagerColumnView = Em.View.extend DragNDrop.Droppable,
  templateName: 'manuscript_manager_column'
  classNames: ['column']

  dragOver: (e) ->
    DragNDrop.draggingStarted('.column', @.$())
    DragNDrop.cancel(e)

  dragEnd: (e) ->
    DragNDrop.draggingStopped('.column')

  drop: (e) ->
    DragNDrop.draggingStopped('.column')
    @get('controller').changeTaskPhase(ETahi.get('dragItem'), @get('content'))
    e.preventDefault()
    false
