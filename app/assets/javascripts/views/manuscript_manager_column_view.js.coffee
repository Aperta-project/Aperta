ETahi.ManuscriptManagerColumnView = Em.View.extend(DragNDrop.Droppable, {
  templateName: 'manuscript_manager_column'
  classNames: ['column']

  dragOver: (e) ->
    DragNDrop.draggingStarted('.column', @.$())
    DragNDrop.cancel(e)

  dragEnd: (e) ->
    DragNDrop.draggingStopped('.column')

  drop: (e) ->
    return false
    taskID = e.originalEvent.dataTransfer.getData('Text')
    @get('controller').changeTaskPhase(taskID, @get('content'))
    e.preventDefault()
    false
})
