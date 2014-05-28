ETahi.AuthorViewComponent = Ember.Component.extend DragNDrop.Dragable,
  tagName: 'li'
  showEditAuthorForm: false
  classNameBindings: ['showEditAuthorForm::edit-inactive']

  dragStart: (e) ->
    ETahi.set('dragItem', @get('content'))

  actions:
    edit: ->
      @set('showEditAuthorForm', true)

    delete: ->
      @get('author').destroyRecord()

    showAuthorForm: ->
      @set('showEditAuthorForm', true)

    hideAuthorForm: ->
      @set('showEditAuthorForm', false)

    saveAuthor: ->
      @get('author').save().then =>
        @set('showEditAuthorForm', false)

