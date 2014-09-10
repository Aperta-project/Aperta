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
      if taskType.get('taskType.kind') == "Task"
        #FIXME: create a new journal task type record which is a copy of the AdHoc type
        @controllerFor('adHocTemplateOverlay').setProperties(phaseTemplate: phaseTemplate, model: taskType)
        @render('adHocTemplateOverlay',
          into: 'application'
          outlet: 'overlay'
          controller: 'adHocTemplateOverlay')
      else
        @send('addTaskAndClose', phaseTemplate, taskType)

    addTaskAndClose: (phaseTemplate, taskType) ->
      @controllerFor('manuscriptManagerTemplateEdit').send('addTask', phaseTemplate, taskType)
      @send('closeOverlay')

    closeAction: ->
      @send('closeOverlay')

    viewCard: -> #no-op
