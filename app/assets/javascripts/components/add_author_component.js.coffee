ETahi.AddAuthorFormComponent = Ember.Component.extend
  tagName: 'div'

  actions:
    toggleAuthorForm: ->
      @sendAction('hideAuthorForm')

    saveNewAuthor: ->
      @sendAction('saveAuthor')

