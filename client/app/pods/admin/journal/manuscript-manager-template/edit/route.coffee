`import Ember from 'ember'`

ManuscriptManagerTemplateEditRoute = Ember.Route.extend
  model: (params) ->
    @store.find('manuscriptManagerTemplate', params.manuscript_manager_template_id)

  afterModel: (model) ->
    model.reload() unless model.get('phaseTemplates.length')

  actions:
    saveChanges: ->
      @controller.send('saveTemplate', @get('attemptingTransition'))

    didRollBack: ->
      # nothing to do here

`export default ManuscriptManagerTemplateEditRoute`
