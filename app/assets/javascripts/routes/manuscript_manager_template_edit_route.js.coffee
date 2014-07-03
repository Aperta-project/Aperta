ETahi.ManuscriptManagerTemplateEditRoute = Ember.Route.extend
  model: (params) ->
    @modelFor('journal')
      .get('manuscriptManagerTemplates')
      .findBy('id', parseInt(params.template_id))

  afterModel: ->
    @set('location', window.location.pathname)

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('journal', @modelFor('journal'))

  actions:
    willTransition: (transition) ->
      if @controller.get('dirty')
        @set('attemptingTransition', transition)
        transition.abort()
        @render 'unsavedDataOverlay',
          into: 'application'
          outlet: 'overlay'
          controller: 'unsavedDataOverlay'
      else
        # Bubble the `willTransition` action so that
        # parent routes can decide whether or not to abort.
        return true
    discardChanges: ->
      @controller.send('rollbackTemplate')
      @get('attemptingTransition').retry()

    cancelTransition: ->
      @send('closeOverlay')

