`import Ember from 'ember'`
`import DragNDrop from 'tahi/services/drag-n-drop'`

PhaseView = Ember.View.extend DragNDrop.DroppableMixin,
  classNames: ['column']
  lastDraggedOverCard: null

  nextPosition: (->
    @get('controller.model.position') + 1
  ).property('controller.model.position')

  removeDragStyles: () ->
    @$().removeClass('current-drop-target')

  dragOver: (e) ->
    @$().addClass('current-drop-target')

    if $(e.target).hasClass("button-secondary")
      $('.placeholder').remove()
      $(e.target).before('<div class="card-content placeholder"></div>')

    if $(e.target).hasClass('card-content') && !$(e.target).hasClass('placeholder')
      $('.placeholder').remove()
      $(e.target).before('<div class="card-content placeholder"></div>')

  dragLeave: (e) ->
    @removeDragStyles()
    @set 'lastDraggedOverCard', e.target

  dragEnd: (e) ->
    @removeDragStyles()
    $('.placeholder').remove()


  drop: (e) ->
    @removeDragStyles()
    draggedTask = DragNDrop.dragItem
    @get('controller').send 'changeTaskPhase', draggedTask, @get('controller.model')

    draggedTask.set('position', 0)
    .save().then (savedTask) -> savedTask.get('phase').reload()

    DragNDrop.dragItem = null
    DragNDrop.cancel(e)

`export default PhaseView`
