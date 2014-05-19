ETahi.AuthorsOverlayView = ETahi.OverlayView.extend
  templateName: 'overlays/authors_overlay'
  layoutName: 'layouts/overlay_layout'

ETahi.AddAuthorView = Ember.View.extend
  attributeBindings: ['newAuthor']
  templateName: 'components/add_author_form'

ETahi.AuthorViewController = Ember.Controller.extend
  showEditAuthorForm: false
  showEditAuthorForm: ->
    @set('showEditAuthorForm', true)
    false

ETahi.AuthorView = Ember.View.extend
  attributeBindings: ['author']
  templateName: 'components/author_form'
  init: ->
    @_super()
    @set("controller", ETahi.AuthorViewController.create())

  click: ->
    debugger
    @get("controller").showEditAuthorForm()

