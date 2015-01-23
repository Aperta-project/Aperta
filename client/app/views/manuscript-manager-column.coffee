`import Ember from 'ember'`
`import Droppable from 'tahi/mixins/droppable'`

ManuscriptManagerColumnView = Em.View.extend Droppable,
  classNames: ['column']

  nextPosition: (->
    @get('content.position') + 1
  ).property('content.position')

  dragOver: (e) ->
    @$().addClass('current-drop-target')
    @cancelDroppableEvent(e)

  dragEnd: (e) ->
    @$().removeClass('current-drop-target')

  drop: (e) ->
    @$().removeClass('current-drop-target')
    @get('controller').send('changeTaskPhase', ETahi.get('dragItem'), @get('content'))
    e.preventDefault()
    false

`export default ManuscriptManagerColumnView`
