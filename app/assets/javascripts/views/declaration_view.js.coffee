ETahi.DeclarationView = Ember.View.extend
  templateName: 'overlays/declaration'
  layoutName: 'layouts/overlay_layout'
  focusOut: (e) ->
    @get('declaration').save()
