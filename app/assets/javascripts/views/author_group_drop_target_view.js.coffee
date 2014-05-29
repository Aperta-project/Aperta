ETahi.AuthorGroupDropTargetView = Ember.View.extend DragNDrop.Droppable,
  tagName: 'div'
  classNames: ['author-drop-target']

  dragOver: (e) ->
    DragNDrop.draggingStarted('.author-drop-target', @.$())
    DragNDrop.cancel(e)

  dragEnd: (e) ->
    DragNDrop.draggingStopped('.author-drop-target')

  drop: (e) ->
    DragNDrop.draggingStopped('.author-drop-target')
    e.preventDefault()
    #dragItem will be the author.
    @get('controller').send('changeAuthorGroup', ETahi.get('dragItem'))
    ETahi.set('dragItem', null)
    false
