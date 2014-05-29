ETahi.AuthorGroupDropTargetView = Ember.View.extend DragNDrop.Droppable,
  tagName: 'div'
  classNames: ['author-drop-target']

  position: ( ->
    @get('index') + 1
  ).property('index')

  dragOver: (e) ->
    DragNDrop.draggingStarted('.author-drop-target', @.$())
    DragNDrop.cancel(e)

  dragEnd: (e) ->
    DragNDrop.draggingStopped('.author-drop-target')

  drop: (e) ->
    DragNDrop.draggingStopped('.author-drop-target')
    e.preventDefault()
    #dragItem will be the author.
    @get('controller').send('changeAuthorGroup', ETahi.get('dragItem'), @get('position'))
    ETahi.set('dragItem', null)
    false
