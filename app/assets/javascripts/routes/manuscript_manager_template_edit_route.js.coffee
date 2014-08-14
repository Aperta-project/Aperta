ETahi.ManuscriptManagerTemplateEditRoute = Ember.Route.extend(ETahi.AlertUnsavedChanges,
  model: (params) ->
    @store.find('manuscriptManagerTemplate', parseInt(params.template_id))

  actions:
    saveChanges: ->
      @controller.send('saveTemplate', @get('attemptingTransition'))

    didRollBack: ->
      # @refresh()
)
