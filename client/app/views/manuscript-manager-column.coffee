`import Ember from 'ember'`
`import DragNDrop from 'ember'`
`import Droppable from 'tahi/mixins/views/droppable'`

ManuscriptManagerColumnView = Em.View.extend Droppable,
  classNames: ['column']

  nextPosition: (->
    @get('content.position') + 1
  ).property('content.position')

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

`export default ManuscriptManagerColumnView`
