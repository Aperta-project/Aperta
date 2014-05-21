ETahi.AddAuthorFormComponent = Ember.Component.extend
  tagName: 'div'
  templateName: 'components/add_author_form'

  actions:
    toggleAuthorForm: ->
      @sendAction('hideAuthorForm')

    saveNewAuthor: ->
      @sendAction('saveAuthor')

