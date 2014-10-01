ETahi.AuthorViewComponent = Ember.Component.extend DragNDrop.Dragable,
  classNames: ['authors-overlay-item']
  classNameBindings: ['hoverState:__hover', 'isEditable:__editable']

  editState: false
  hoverState: false
  deleteState: false

  attachHoverEvent: (->
    self = this
    toggleHoverClass = (e) ->
      self.toggleProperty 'hoverState'

    @$().hover(toggleHoverClass, toggleHoverClass)
  ).on('didInsertElement')

  teardownHoverEvent: (->
    @$().off('mouseenter mouseleave');
  ).on('willDestroyElement')

  dragStart: (e) ->
    e.dataTransfer.effectAllowed = 'move'
    ETahi.set('dragItem', @get('author'))

  dragEnd: (e) ->
    DragNDrop.draggingStopped('.author-drop-target')

  actions:
    delete: ->
      @sendAction 'delete', @get('author')

    save: ->
      @sendAction 'save', @get('author')
      @set 'editState', false

    toggleEditForm: ->
      @toggleProperty 'editState'

    toggleDeleteConfirmation: ->
      @toggleProperty 'deleteState'
