ETahi.ApplicationRoute = Ember.Route.extend ETahi.AnimateElement,
  setupController: (controller, model) ->
    if @getCurrentUser? && @getCurrentUser()
      authorize = (value) ->
        (result) ->
          Ember.run ->
            controller.set('canViewAdminLinks', value)
      Ember.$.ajax '/admin/journals/authorization',
        headers:
          'Tahi-Authorization-Check': true
        success: authorize(true)
        error:authorize(false)

    @_super(model, controller)

  actions:
    loading: (transition, originRoute) ->
      spinner = @Spinner.create()
      @set('spinner', spinner)
      @router.one('didTransition', spinner, 'stop')

    error: (response, transition, originRoute) ->
      transition.abort()
      @get('spinner')?.stop()

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
        @store.createRecord('participation', participant: currentUser, task: newTask)
        newTask.get('comments').pushObject(@store.createRecord('comment', commenter: currentUser))

      taskParticipations = @store.filter 'participation', (part) ->
        part.get('task') == newTask

      @controllerFor(controllerName).setProperties({
        model: newTask
        paper: paper
        participations: taskParticipations
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

    addPaperToEventStream: (paper) ->
      @eventStream.addEventListener(paper.get('eventName'))

    editableDidChange: -> null #noop, this is caught by paper.edit and paper.index

    feedback: ->
      @render('feedback',
        into: 'application'
        outlet: 'overlay')
