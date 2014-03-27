ETahi.AuthorsOverlayView = Ember.View.extend
  templateName: 'overlays/authors_overlay'
  layoutName: 'layouts/assignee_overlay_layout'

ETahi.AddAuthorView = Ember.View.extend
  attributeBindings: ['newAuthor']
  templateName: 'components/add_author_form'
