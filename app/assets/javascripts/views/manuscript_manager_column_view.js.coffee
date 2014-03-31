ETahi.ManuscriptManagerColumnView = Em.View.extend(DragNDrop.Droppable, {
  templateName: 'manuscript_manager_column'
  tagName: 'li'
  classNames: ['column']

  drop: (e) ->
    return false
    taskID = e.originalEvent.dataTransfer.getData('Text')
    @get('controller').changeTaskPhase(taskID, @get('content'))
    e.preventDefault()
    false
})
