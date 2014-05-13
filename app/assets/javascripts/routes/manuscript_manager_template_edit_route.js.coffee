ETahi.ManuscriptManagerTemplateEditRoute = Ember.Route.extend
  model: (params) ->
    @modelFor('journal')
      .get('manuscriptManagerTemplates')
      .findBy('id', parseInt(params.template_id))

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('journal', @modelFor('journal'))

  actions:
    chooseNewCardTypeOverlay: (phase) ->
      taskTypes = @controllerFor('manuscriptManagerTemplate').get('taskTypes')
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
