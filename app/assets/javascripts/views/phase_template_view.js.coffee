ETahi.PhaseTemplateView = Em.View.extend DragNDrop.Droppable,
  templateName: 'phase_template'
  classNames: ['column']

  dragOver: (e) ->
    DragNDrop.draggingStarted('.column', @.$())
    DragNDrop.cancel(e)

  dragEnd: (e) ->
    DragNDrop.draggingStopped('.column')

  drop: (e) ->
    DragNDrop.draggingStopped('.column')
    @get('controller').send('moveTaskTemplate', ETahi.get('dragItem'))
    e.preventDefault()
    false

