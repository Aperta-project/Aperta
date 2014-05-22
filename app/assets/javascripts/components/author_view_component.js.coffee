ETahi.AuthorViewComponent = Ember.Component.extend
  tagName: 'li'
  templateName: 'components/author_view'
  showEditAuthorForm: false

  showAuthorForm: ->
    @set('showEditAuthorForm', true)

  hideAuthorForm: ->
    @set('showEditAuthorForm', false)

  saveAuthor: ->
    @get('author').save().then =>
      @hideAuthorForm()

  click: (e)->
    return if e.target.classList.contains('author-cancel')
    @showAuthorForm()

