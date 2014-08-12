ETahi.ManuscriptManagerTemplateNewRoute = Ember.Route.extend(ETahi.AlertUnsavedChanges,
  controllerName: 'manuscriptManagerTemplateEdit'

  model: (params) ->
    journal = @modelFor('journal')
    newTemplate = @store.createRecord 'manuscriptManagerTemplate',
      journal:   journal
      paperType: "Research"

    phase1 = @store.createRecord 'phaseTemplate',
      manuscriptManagerTemplate: newTemplate
      name: "Phase 1"
      position: 0

    phase2 = @store.createRecord 'phaseTemplate',
      manuscriptManagerTemplate: newTemplate
      name: "Phase 2"
      position: 1

    phase3 = @store.createRecord 'phaseTemplate',
      manuscriptManagerTemplate: newTemplate
      name: "Phase 3"
      position: 2

    newTemplate

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('journal', @modelFor('journal'))

  renderTemplate: ->
    @render 'manuscript_manager_template/edit'
)
