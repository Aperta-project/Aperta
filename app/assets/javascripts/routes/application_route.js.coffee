ETahi.ApplicationRoute = Ember.Route.extend
  activate: ->
    $('#ember-app-loading').remove()

  actions:
    loading: (transition, originRoute) ->
      @controllerFor('application').set('isLoading', true)
      this.router.one 'didTransition', =>
        @controllerFor('application').set('isLoading', false)

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
      newTaskParams = {phase: phase, type: taskType.replace(/^new/, ''), paper_id: paper.get('id')}
      newTask = @store.createRecord(taskType, newTaskParams)
      controllerName = 'newCardOverlay'
      if taskType == 'MessageTask'
        controllerName = 'newMessageCardOverlay'
        currentUser = @controllerFor('application').get('currentUser')
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
      ETahi.animateOverlayOut().then =>
        @disconnectOutlet
          outlet: 'overlay'
          parentView: 'application'
