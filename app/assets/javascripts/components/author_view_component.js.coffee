ETahi.AuthorViewComponent = Ember.Component.extend DragNDrop.Dragable,
  tagName: 'li'
  showEditAuthorForm: false
  classNameBindings: ['showEditAuthorForm::edit-inactive', 'isEditable:editable']

  attachHover: ( ->
    toggleHoverClass = (e) ->
      $(this).toggleClass('hover')

    @$().hover(toggleHoverClass, toggleHoverClass)
  ).on('didInsertElement')

  dragStart: (e) ->
    e.dataTransfer.effectAllowed = 'move'
    ETahi.set('dragItem', @get('author'))

  dragEnd: (e) ->
    DragNDrop.draggingStopped('.author-drop-target')

  actions:
    edit: ->
      @set('showEditAuthorForm', true)

    delete: ->
      @sendAction('delete', @get('author'))

    showAuthorForm: ->
      @set('showEditAuthorForm', true)

    hideAuthorForm: ->
      @set('showEditAuthorForm', false)

    saveAuthor: ->
      @sendAction('save', @get('author'))
      @set('showEditAuthorForm', false)
