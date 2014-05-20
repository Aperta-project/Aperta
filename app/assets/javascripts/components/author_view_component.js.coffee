ETahi.AuthorViewComponent = Ember.Component.extend
  tagName: 'li'
  templateName: 'components/author_form'
  showEditAuthorForm: false

  editAuthorForm: ->
    @set('showEditAuthorForm', true)

  toggleEditAuthorForm: ->
    @set('showEditAuthorForm', false)

  saveAuthor: ->
    @get('author').save()

  click: (e)->
    return if e.target.classList.contains('author-cancel')
    @editAuthorForm()

