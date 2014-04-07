ETahi.ApplicationRoute = Ember.Route.extend
  actions:
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

      if taskType == 'MessageTask'
        newTask.get('participants').pushObject(@controllerFor('application').get('currentUser'))

      @controllerFor('newCardOverlay').setProperties({
        model: newTask
        paper: paper
      })

      @render(tmplName,
        into: 'application'
        outlet: 'overlay'
        controller: 'newCardOverlay')

    closeOverlay: ->
      ETahi.animateOverlayOut().then =>
        @disconnectOutlet
          outlet: 'overlay'
          parentView: 'application'
