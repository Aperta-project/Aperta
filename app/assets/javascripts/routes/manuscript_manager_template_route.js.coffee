ETahi.ManuscriptManagerTemplateRoute = Ember.Route.extend
  actions:
    chooseNewCardTypeOverlay: (phaseTemplate) ->
      journalTaskTypes = @modelFor('journal').get('journalTaskTypes')
      @controllerFor('chooseNewCardTypeOverlay').setProperties(phaseTemplate: phaseTemplate, journalTaskTypes: journalTaskTypes)
      @render('add_manuscript_template_card_overlay',
        into: 'application'
        outlet: 'overlay'
        controller: 'chooseNewCardTypeOverlay')

    addTaskType: (phaseTemplate, taskType) ->
      newTask = @store.createRecord('taskTemplate',
        title: taskType.get('title')
        journalTaskType: taskType
        phaseTemplate: phaseTemplate
        template: [])
      if taskType.get('kind') == "Task"
        @controllerFor('adHocTemplateOverlay').setProperties(phaseTemplate: phaseTemplate, model: newTask, isNewTask: true)
        @render('adHocTemplateOverlay',
          into: 'application'
          outlet: 'overlay'
          controller: 'adHocTemplateOverlay')
      else
        @send('addTaskAndClose')

    addTaskAndClose: ->
      @controllerFor('manuscriptManagerTemplateEdit').set('dirty', true)
      @send('closeOverlay')

    closeAction: ->
      @send('closeOverlay')

    viewCard: -> #no-op
