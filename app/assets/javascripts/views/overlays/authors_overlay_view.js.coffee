ETahi.AuthorsOverlayView = Ember.View.extend
  templateName: 'overlays/authors_overlay'
  layoutName: 'layouts/assignee_overlay_layout'
  actions:
    addNewAuthor: -> @get('controller').send('addNewAuthor')

ETahi.AddAuthorView = Ember.View.extend
  templateName: 'components/add_author_form'
