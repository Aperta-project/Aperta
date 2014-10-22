ETahi.AddAuthorFormComponent = Ember.Component.extend
  layoutName: "plos_authors/components/add-author-form"
  tagName: 'div'

  setNewAuthor: ( ->
    unless @get('newAuthor')
      @set('newAuthor', {})
  ).on('init')

  clearNewAuthor: ->
    if Ember.typeOf(@get('newAuthor')) == 'object'
      @set('newAuthor', {})

  actions:
    cancelEdit: ->
      @clearNewAuthor()
      @sendAction('hideAuthorForm')

    saveNewAuthor: ->
      author = @get('newAuthor')
      @sendAction('saveAuthor', author)
      @clearNewAuthor()

