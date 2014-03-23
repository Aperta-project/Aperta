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

      newTask = @store.createRecord(taskType,
        {phase: phase, type: taskType.replace(/^new/, ''), paper_id: paper.get('id')})

      @controllerFor('newCardOverlay').set('model', newTask)

      @render(tmplName,
        into: 'application'
        outlet: 'overlay'
        controller: 'newCardOverlay')

    closeOverlay: ->
      @disconnectOutlet(
        outlet: 'overlay'
        parentView: 'application')
