ETahi.ManuscriptManagerTemplateNewRoute = Ember.Route.extend ETahi.AlertUnsavedChanges,
  controllerName: 'manuscriptManagerTemplateEdit'

  model: (params) ->
    journal = @modelFor('journal')
    newTemplate = @store.createRecord 'manuscriptManagerTemplate',
      journal:   journal
      paperType: "Research"

    newTemplate.get('phaseTemplates').pushObject
      @store.createRecord 'phaseTemplate', name: "Phase 1", position: 1

    newTemplate.get('phaseTemplates').pushObject
      @store.createRecord 'phaseTemplate', name: "Phase 2", position: 2

    newTemplate.get('phaseTemplates').pushObject
      @store.createRecord 'phaseTemplate', name: "Phase 3", position: 3

    @set('journal', journal)
    @set('newTemplate', newTemplate)
    newTemplate

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('journal', @modelFor('journal'))

  renderTemplate: ->
    @render 'manuscript_manager_template/edit'

  actions:
    didRollBack: ->
      @get('journal.manuscriptManagerTemplates').removeObject(@get('newTemplate'))
      @transitionTo('journal')
