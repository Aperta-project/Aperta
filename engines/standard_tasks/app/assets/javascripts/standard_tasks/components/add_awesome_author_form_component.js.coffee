ETahi.AddAwesomeAuthorFormComponent = Ember.Component.extend
  actions:
    saveAuthor: (author) ->
      @sendAction('saveAuthor', author)
