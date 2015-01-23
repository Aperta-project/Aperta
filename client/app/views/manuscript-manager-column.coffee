`import Ember from 'ember'`
`import DragNDrop from 'tahi/services/drag-n-drop'`


ManuscriptManagerColumnView = Ember.View.extend DragNDrop.DroppableMixin,
  classNames: ['column']

  nextPosition: (->
    @get('content.position') + 1
  ).property('content.position')

  removeDragStyles: () ->
    @$().removeClass('current-drop-target')

  dragOver: (e) ->
    @$().addClass('current-drop-target')

  dragLeave: ->
    @removeDragStyles()

  dragEnd: ->
    @removeDragStyles()

  drop: (e) ->
    @removeDragStyles()
    @get('controller').send 'changeTaskPhase', DragNDrop.dragItem, @get('content')
    DragNDrop.cancel(e)

`export default ManuscriptManagerColumnView`
