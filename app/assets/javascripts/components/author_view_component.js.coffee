ETahi.AuthorViewComponent = Ember.Component.extend DragNDrop.Dragable,
  classNames: ['authors-overlay-item']
  classNameBindings: ['hoverState:__hover', 'isEditable:__editable']

  editState: false
  hoverState: false
  deleteState: false

  attachHoverEvent: (->
    toggleHoverClass = (e) =>
      @toggleProperty 'hoverState'

    @$().hover toggleHoverClass, toggleHoverClass
  ).on('didInsertElement')

  teardownHoverEvent: (->
    @$().off('mouseenter mouseleave')
  ).on('willDestroyElement')

  errors: (->
    @get('origContext').associatedErrors(@get('plosAuthor'))
  ).property('origContext.validationErrors').volatile()

  dragStart: (e) ->
    e.dataTransfer.effectAllowed = 'move'
    ETahi.set('dragItem', @get('plosAuthor'))

  dragEnd: (e) ->
    DragNDrop.draggingStopped('.author-drop-target')

  actions:
    delete: ->
      @$().fadeOut 250, =>
        @sendAction 'delete', @get('plosAuthor')

    save: ->
      @sendAction 'save', @get('plosAuthor')
      @set 'editState', false

    toggleEditForm: ->
      @toggleProperty 'editState'

    toggleDeleteConfirmation: ->
      @toggleProperty 'deleteState'
