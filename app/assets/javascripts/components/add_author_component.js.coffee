ETahi.AddAuthorFormComponent = Ember.Component.extend
  tagName: 'div'
  templateName: 'components/add_author_form'

  actions:
    toggleAuthorForm: ->
      @sendAction('toggleEditAuthorForm')

    saveNewAuthor: ->
      @sendAction('saveAuthor')

