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

  selectableInstitutions: (->
    @get('institutions').map (institution) ->
      id: institution
      text: institution
  ).property('institutions')

  selectedAffiliation: (->
    id: @get('newAuthor.affiliation')
    text: @get('newAuthor.affiliation')
  ).property('newAuthor')

  selectedSecondaryAffiliation: (->
    id: @get('newAuthor.secondaryAffiliation')
    text: @get('newAuthor.secondaryAffiliation')
  ).property('newAuthor')


  actions:
    cancelEdit: ->
      @clearNewAuthor()
      @sendAction('hideAuthorForm')

    saveNewAuthor: ->
      author = @get('newAuthor')
      @sendAction('saveAuthor', author)
      @clearNewAuthor()

