ETahi.ApplicationRoute = Ember.Route.extend
  actions:
    showTaskOverlay: (task) ->
      taskName = task.get('type').replace(/Task$/,'')
      @controllerFor('task').set('model', task)
      @render(taskName,
        into: 'application'
        outlet: 'overlay'
        controller: 'task')

    showNewCardOverlay: (phase) ->
      @controllerFor('newCard').set('phase', phase)

      @render('new_card',
        into: 'application'
        outlet: 'overlay'
        controller: 'newCard')

    cardCreationOverlay: (phase) ->
      paper = @controllerFor('paperManage').get('model')
      task = @store.createRecord('task', {phase: phase})

      @controllerFor('newTask').set('paper', paper)
      @controllerFor('newTask').set('task', task)

      @render('newTask',
        into: 'application'
        outlet: 'overlay'
        controller: 'newTask')

    closeOverlay: ->
      @disconnectOutlet(
        outlet: 'overlay'
        parentView: 'application')
