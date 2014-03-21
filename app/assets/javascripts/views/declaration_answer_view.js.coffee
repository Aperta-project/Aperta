ETahi.DeclarationView = Ember.View.extend
  templateName: 'overlays/declaration'
  focusOut: (e) ->
    @get('controller').send('save', @get('declaration'))
