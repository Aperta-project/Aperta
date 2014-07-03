ETahi.ManuscriptManagerTemplateNewRoute = Ember.Route.extend(ETahi.AlertUnsavedChanges,
  controllerName: 'manuscriptManagerTemplateEdit'

  model: (params) ->
    journal = @modelFor('journal')
    newTemplate = ETahi.ManuscriptManagerTemplate.create(
      journal_id: journal.id
      template:
        phases: [
          {
            name: "Phase 1"
            task_types: []
          }
          {
            name: "Phase 2"
            task_types: []
          }
          {
            name: "Phase 3"
            task_types: []
          }
        ]
    )
    journal.get('manuscriptManagerTemplates').pushObject(newTemplate)

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('journal', @modelFor('journal'))

  renderTemplate: ->
    @render 'manuscript_manager_template/edit'
)
