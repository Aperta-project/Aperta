`import Ember from 'ember'`

DragNDrop = Ember.Namespace.create

  cancel: (e) ->
    e.preventDefault()
    false

  draggingStarted: (dropTargetsSelector, currentDropTarget)->
    $(dropTargetsSelector).removeClass('current-drop-target').addClass('not-drop-target')
    $(currentDropTarget).removeClass('not-drop-target').addClass('current-drop-target')

  draggingStopped: (dropTargetsSelector)->
    $(dropTargetsSelector).removeClass('current-drop-target').removeClass('not-drop-target')

`export default DragNDrop`
