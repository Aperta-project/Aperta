ETahi.ApplicationRoute = Ember.Route.extend ETahi.AnimateElement,
  setupController: (controller, model) ->
    if @getCurrentUser? && @getCurrentUser()
      authorize = (value) -> (result) -> controller.set('canViewAdminLinks', value)
      @store.find('adminJournal').then(authorize(true), authorize(false))

    @_super(model, controller)

  actions:
    loading: (transition, originRoute) ->
      spinner = @Spinner.create()
      @set('spinner', spinner)
      @router.one('didTransition', spinner, 'stop')

    error: (response, transition, originRoute) ->
      transition.abort()
      @get('spinner')?.stop()

    chooseNewCardTypeOverlay: (phase) ->
      @controllerFor('chooseNewCardTypeOverlay').set('phase', phase)
      @render('chooseNewCardTypeOverlay',
        into: 'application'
        outlet: 'overlay'
        controller: 'chooseNewCardTypeOverlay')

    showTaskCreationOverlay: (phase) ->
      @send('showNewCardOverlay', 'newAdHocTaskOverlay', 'Task', phase)

    showMessageCreationOverlay: (phase) ->
      @send('showNewCardOverlay', 'newMessageTask', 'MessageTask', phase)

    showNewCardOverlay: (tmplName, taskType, phase) ->
      paper = @controllerFor('paperManage').get('model')
      newTaskParams = {phase: phase, type: taskType.replace(/^new/, ''), paper: paper}
      newTask = @store.createRecord(taskType, newTaskParams)
      controllerName = 'newCardOverlay'
      if taskType == 'MessageTask'
        controllerName = 'newMessageCardOverlay'
        currentUser = @getCurrentUser()
        newTask.get('participants').pushObject(currentUser)
        newTask.get('comments').pushObject(@store.createRecord('comment', commenter: currentUser))

      @controllerFor(controllerName).setProperties({
        model: newTask
        paper: paper
      })

      @render(tmplName,
        into: 'application'
        outlet: 'overlay'
        controller: controllerName)

    closeOverlay: ->
      @animateOverlayOut().then =>
        @disconnectOutlet
          outlet: 'overlay'
          parentView: 'application'

    closeAction: ->
      @send('closeOverlay')

    didCreatePaper: (paper) ->
      @eventStream.addEventListener(paper.get('eventName'))
