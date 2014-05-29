ETahi.AddAuthorFormComponent = Ember.Component.extend
  tagName: 'div'

  setNewAuthor: ( ->
    unless @get('newAuthor')
      @set('newAuthor', {})
  ).on('init')

  actions:
    toggleAuthorForm: ->
      @sendAction('hideAuthorForm')

    saveNewAuthor: ->
      author = @get('newAuthor')
      @sendAction('saveAuthor', author)
      if Ember.typeOf(author) == 'object'
        @set('newAuthor', {})

