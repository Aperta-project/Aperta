ETahi.AuthorsOverlayView = ETahi.OverlayView.extend
  templateName: 'overlays/authors_overlay'
  layoutName: 'layouts/overlay_layout'

ETahi.AddAuthorView = Ember.View.extend
  attributeBindings: ['newAuthor']
  templateName: 'components/add_author_form'
