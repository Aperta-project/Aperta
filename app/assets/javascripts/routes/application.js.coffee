ETahi.ApplicationRoute = Ember.Route.extend
  actions:
    showNewCardOverlay: (phase) ->
      @controllerFor('newCard').set('phase', phase)

      @render('new_card',
        into: 'application'
        outlet: 'overlay'
        controller: 'newCard')

    cardCreationOverlay: (phase) ->
      @send('someCardOverlay', 'newTask', 'Task', phase)

    messageCreationOverlay: (phase) ->
      @send('someCardOverlay', 'newMessageTask', 'MessageTask', phase)

    someCardOverlay: (tmplName, taskType, phase) ->
      paper = @controllerFor('paperManage').get('model')
      task = @store.createRecord(taskType,
        {phase: phase, type: taskType.replace(/^new/, ''), paper_id: paper.get('id')})
      task.type = task.class

      @controllerFor('newTask').set('model', task)

      @render(tmplName,
        into: 'application'
        outlet: 'overlay'
        controller: 'newTask')

    closeOverlay: ->
      @disconnectOutlet(
        outlet: 'overlay'
        parentView: 'application')
