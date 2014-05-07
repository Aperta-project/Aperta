ETahi.ManuscriptManagerTemplateNewRoute = Ember.Route.extend
  controllerName: 'manuscriptManagerTemplateEdit'

  model: (params) ->
    journal = @modelFor('journal')
    newTemplate = ETahi.ManuscriptManagerTemplate.create(
      journal_id: journal.id
      template:
        phases: [
          name: "New Phase"
          task_types: []
        ]
    )
    @modelFor('manuscriptManagerTemplate').pushObject(newTemplate)

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('journal', @modelFor('journal'))

  renderTemplate: ->
    @render 'manuscript_manager_template/edit'

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
