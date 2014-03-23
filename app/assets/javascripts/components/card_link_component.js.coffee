ETahi.CardLinkComponent = Ember.Component.extend
  taskHref:( ->
    "#/papers/#{@get('paper.id')}/tasks/#{@get('task.id')}"
  ).property('paper.id', 'task.id')

  click: (e) ->
    if $(e.target).hasClass('js-remove-card')
      @sendAction('action', @get('task'))

  setupTooltip: (->
    @.$().find('.js-remove-card').tooltip()
  ).on('didInsertElement')
