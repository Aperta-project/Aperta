ETahi.AuthorViewComponent = Ember.Component.extend
  tagName: 'li'
  showEditAuthorForm: false
  classNameBindings: ['showEditAuthorForm::edit-inactive']


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

