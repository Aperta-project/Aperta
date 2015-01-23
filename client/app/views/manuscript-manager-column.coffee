`import Ember from 'ember'`
`import Droppable from 'tahi/mixins/droppable'`

ManuscriptManagerColumnView = Em.View.extend Droppable,
  classNames: ['column']

  nextPosition: (->
    @get('content.position') + 1
  ).property('content.position')

  dragDidEnd: (e) ->
    @$().removeClass('current-drop-target')

  dragOver: (e) ->
    @$().addClass('current-drop-target')
    @cancelDroppableEvent(e)

  dragLeave: (e) ->
    @dragDidEnd(e)

  dragEnd: (e) ->
    @dragDidEnd(e)

  drop: (e) ->
    @dragDidEnd(e)
    @get('controller').send('changeTaskPhase', ETahi.get('dragItem'), @get('content'))
    e.preventDefault()
    false

`export default ManuscriptManagerColumnView`
