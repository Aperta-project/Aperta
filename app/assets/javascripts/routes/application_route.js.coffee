ETahi.ApplicationRoute = Ember.Route.extend ETahi.AnimateElement,
  setupController: (controller, model) ->
    controller.set('model', model)
    if @getCurrentUser? && @getCurrentUser()
      ETahi.RESTless.authorize(controller, '/admin/journals/authorization', 'canViewAdminLinks')
      ETahi.RESTless.authorize(controller, '/user_flows/authorization', 'canViewFlowManagerLink')

  actions:
    loading: (transition, originRoute) ->
      spinner = @Spinner.create()
      @set('spinner', spinner)
      @router.one('didTransition', spinner, 'stop')

    error: (response, transition, originRoute) ->
      oldState = transition.router.oldState
      transitionMsg = if oldState
                        lastRoute = _.last(oldState.handlerInfos).name
                        "Error in transition from #{lastRoute} to #{transition.targetName}"
                      else
                        "Error in transition into #{transition.targetName}"
      @logError(transitionMsg + "\n" + response.message + "\n" + response.stack + "\n")
      transition.abort()
      @get('spinner')?.stop()

    closeOverlay: ->
      @animateOverlayOut().then =>
        @disconnectOutlet
          outlet: 'overlay'
          parentView: 'application'

    closeAction: ->
      @send('closeOverlay')

    addPaperToEventStream: (paper) ->
      @eventStream.addEventListener(paper.get('eventName'))

    editableDidChange: -> null #noop, this is caught by paper.edit and paper.index

    feedback: ->
      @render('feedback',
        into: 'application'
        outlet: 'overlay')
