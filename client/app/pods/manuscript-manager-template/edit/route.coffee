`import Ember from 'ember'`
`import AlertUnsavedChanges from 'tahi/mixins/routes/alert-unsaved-changes'`

ManuscriptManagerTemplateEditRoute = Ember.Route.extend AlertUnsavedChanges,
  model: (params) ->
    @store.find('manuscriptManagerTemplate', parseInt(params.manuscript_manager_template_id))

  afterModel: (model) ->
    model.reload() unless model.get('phaseTemplates.length')

  actions:
    saveChanges: ->
      @controller.send('saveTemplate', @get('attemptingTransition'))

    didRollBack: ->
      # nothing to do here

`export default ManuscriptManagerTemplateEditRoute`
