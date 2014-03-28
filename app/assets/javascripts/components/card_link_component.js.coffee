ETahi.CardLinkComponent = Ember.Component.extend
  classNameBindings: ['completed:completed', 'isMessage:message']

  click: (e) ->
    if $(e.target).hasClass('js-remove-card')
      @sendAction('action', @get('task'))

  setupTooltip: (->
    @.$().find('.js-remove-card').tooltip()
  ).on('didInsertElement')
