ETahi.ManuscriptManagerTemplateRoute = Ember.Route.extend
  actions:
    chooseNewCardTypeOverlay: (phaseTemplate) ->
      console.log(phaseTemplate.toString())
      journalTaskTypes = @modelFor('journal').get('journalTaskTypes')
      @controllerFor('chooseNewCardTypeOverlay').setProperties(phaseTemplate: phaseTemplate, journalTaskTypes: journalTaskTypes)
      @render('add_manuscript_template_card_overlay',
        into: 'application'
        outlet: 'overlay'
        controller: 'chooseNewCardTypeOverlay')

    addTaskType: (phaseTemplate, taskType) ->
      @controllerFor('manuscriptManagerTemplateEdit').send('addTask', phaseTemplate, taskType)
      @send('closeOverlay')

    closeAction: ->
      @send('closeOverlay')

    viewCard: -> #no-op
