`import Ember from 'ember'`
`import AnimateElement from 'tahi/mixins/routes/animate-element'`
`import RESTless from 'tahi/services/rest-less'`

ApplicationRoute = Ember.Route.extend AnimateElement,
  setupController: (controller, model) ->
    controller.set('model', model)
    if @currentUser
      RESTless.authorize(controller, '/admin/journals/authorization', 'canViewAdminLinks')
      RESTless.authorize(controller, '/user_flows/authorization', 'canViewFlowManagerLink')

  actions:
    willTransition: (transition) ->
      appController = @controllerFor('application')
      currentRouteController = @controllerFor(appController.get('currentRouteName'))

      if currentRouteController.get('isUploading')
        if confirm 'You are uploading. Are you sure you want abort uploading?'
          currentRouteController.send 'cancelUploads'
        else
          transition.abort()
          return

      appController.send 'hideNavigation'
      appController.set 'isLoading', true

    didTransition: ->
      @controllerFor('application').set 'isLoading', false

    error: (response, transition, originRoute) ->
      oldState = transition.router.oldState
      transitionMsg = if oldState
        lastRoute = oldState.handlerInfos.get('lastObject.name')
        "Error in transition from #{lastRoute} to #{transition.targetName}"
      else
        "Error in transition into #{transition.targetName}"

      @logError(transitionMsg + "\n" + response.message + "\n" + response.stack + "\n")
      transition.abort()
      @controllerFor('application').set 'isLoading', false

    closeOverlay: ->
      @flash.clearMessages()
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
      @render('overlays/feedback',
        into: 'application'
        outlet: 'overlay'
        controller: 'overlays/feedback')

`export default ApplicationRoute`
