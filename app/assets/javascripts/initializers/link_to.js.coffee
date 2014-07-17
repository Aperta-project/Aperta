ETahi.initializer
  name: 'reopenLinkTo'

  initialize: (container, application) ->
    Ember.LinkView.reopen
      attributeBindings: ['data-toggle', 'data-placement', 'title']
