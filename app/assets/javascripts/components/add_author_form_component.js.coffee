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
      @sendAction('saveAuthor', @get('newAuthor'))

