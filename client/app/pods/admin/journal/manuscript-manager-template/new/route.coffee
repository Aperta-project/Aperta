`import Ember from 'ember'`
`import AlertUnsavedChanges from 'tahi/mixins/routes/alert-unsaved-changes'`

ManuscriptManagerTemplateNewRoute = Ember.Route.extend AlertUnsavedChanges,
  controllerName: 'manuscript-manager-template/edit'

  model: (params) ->
    journal = @modelFor('journal')
    newTemplate = @store.createRecord 'manuscriptManagerTemplate',
      journal:   journal
      paperType: "Research"

    newTemplate.get('phaseTemplates').pushObject(
      @store.createRecord('phaseTemplate', name: "Phase 1", position: 1)
    )

    newTemplate.get('phaseTemplates').pushObject(
      @store.createRecord('phaseTemplate', name: "Phase 2", position: 2)
    )

    newTemplate.get('phaseTemplates').pushObject(
      @store.createRecord('phaseTemplate', name: "Phase 3", position: 3)
    )

    @set('journal', journal)
    @set('newTemplate', newTemplate)
    newTemplate

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('journal', @modelFor('journal'))

  renderTemplate: ->
    @render 'admin/journal/manuscript_manager_template/edit'

  actions:
    didRollBack: ->
      @get('admin/journal.manuscriptManagerTemplates').removeObject(@get('newTemplate'))
      @transitionTo('admin/journal')

`export default ManuscriptManagerTemplateNewRoute`
