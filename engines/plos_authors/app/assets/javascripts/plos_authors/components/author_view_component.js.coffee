ETahi.AuthorViewComponent = Ember.Component.extend DragNDrop.Dragable, ETahi.ValidationErrorsMixin,
  layoutName: "plos_authors/components/author-view"
  classNames: ['authors-overlay-item']
  classNameBindings: ['hoverState:__hover', 'isEditable:__editable']

  hoverState: false
  deleteState: false
  editState: (->
    !!@get('author.errors')
  ).property('author.errors')

  attachHoverEvent: (->
    toggleHoverClass = (e) =>
      @toggleProperty 'hoverState'

    @$().hover toggleHoverClass, toggleHoverClass
  ).on('didInsertElement')

  teardownHoverEvent: (->
    @$().off('mouseenter mouseleave')
  ).on('willDestroyElement')

  dragStart: (e) ->
    e.dataTransfer.effectAllowed = 'move'
    ETahi.set('dragItem', @get('author.model'))

  dragEnd: (e) ->
    DragNDrop.draggingStopped('.author-drop-target')

  actions:
    delete: ->
      @$().fadeOut 250, =>
        @sendAction 'delete', @get('author.model')

    save: ->
      @sendAction 'save', @get('author.model')
      @set 'editState', false

    toggleEditForm: ->
      @toggleProperty 'editState'

    toggleDeleteConfirmation: ->
      @toggleProperty 'deleteState'
