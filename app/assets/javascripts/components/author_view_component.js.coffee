ETahi.AuthorViewComponent = Ember.Component.extend
  tagName: 'li'
  templateName: 'components/author_form'
  showEditAuthorForm: false

  editAuthorForm: ->
    @set('showEditAuthorForm', true)

  toggleEditAuthorForm: ->
    # this seems to be changing the property correctly
    @set('showEditAuthorForm', false)

  saveAuthor: ->
    # author needs to become a full object
    @get('author').save()

  click: ->
    @editAuthorForm()

