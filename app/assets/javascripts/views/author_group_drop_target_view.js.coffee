ETahi.AuthorGroupDropTargetView = Ember.View.extend DragNDrop.Droppable,
  tagName: 'div'
  classNames: ['author-drop-target']

  authorGroup: Ember.computed.alias('controller.model')
  position: ( ->
    @get('index') + 1
  ).property('index')

  notAdjacent: (thisPosition, dragItemPosition) ->
    thisPosition <= (dragItemPosition - 1) || thisPosition > (dragItemPosition + 1)

  authorGroupsAreDifferent: ->
    @get('authorGroup') != ETahi.get('dragItem.authorGroup')

  dragEnter: (e) ->
    if @authorGroupsAreDifferent() || @notAdjacent(this.get('position'), ETahi.get('dragItem.position'))
      DragNDrop.draggingStarted('.author-drop-target', @.$())
      DragNDrop.cancel(e)

  dragLeave: (e) ->
    DragNDrop.draggingStopped('.author-drop-target')

  drop: (e) ->
    DragNDrop.draggingStopped('.author-drop-target')
    e.preventDefault()
    #dragItem will be the author.
    @get('controller').send('changeAuthorGroup', ETahi.get('dragItem'), @get('position'))
    ETahi.set('dragItem', null)
    false
