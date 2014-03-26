ETahi.AuthorsOverlayView = Ember.View.extend
  templateName: 'overlays/authors_overlay'
  layoutName: 'layouts/assignee_overlay_layout'
  didInsertElement: ->
    $('.add-author-form').hide()
  actions:
    addNewAuthor: ->
      $('.add-author-form').show()

ETahi.AddAuthorView = Ember.View.extend
  templateName: 'components/add_author_form'
  actions:
    saveNewAuthor: =>

