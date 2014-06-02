ETahi.ManuscriptManagerTemplateRoute = Ember.Route.extend
  actions:
    chooseNewCardTypeOverlay: (phase) ->
      taskTypes = @modelFor('journal').get('taskTypes')
      @controllerFor('chooseNewCardTypeOverlay').setProperties(phase: phase, taskTypes: taskTypes)
      @render('add_manuscript_template_card_overlay',
        into: 'application'
        outlet: 'overlay'
        controller: 'chooseNewCardTypeOverlay')

    addTaskType: (phase, taskType) ->
      @controllerFor('manuscriptManagerTemplateEdit').send('addTask', phase, taskType)
      @send('closeOverlay')

    closeAction: ->
      @send('closeOverlay')

    viewCard: -> #no-op
