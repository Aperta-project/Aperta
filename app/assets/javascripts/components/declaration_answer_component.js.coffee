ETahi.DeclarationAnswerComponent = Ember.TextArea.extend
  focusOut: (e) ->
    @get('declaration').save()
