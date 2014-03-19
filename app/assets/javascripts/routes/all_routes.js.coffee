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

ETahi.PaperRoute = Ember.Route.extend
  model: (params) ->
    @store.find('paper', params.paper_id)

ETahi.PaperManageRoute = Ember.Route.extend
  model: ->
    @modelFor 'paper'

ETahi.PaperTaskRoute = Ember.Route.extend
  model: (params) ->
    paperTasks = _.flatten @modelFor('paper').get('phases').mapProperty('tasks.content')
    paperTasks.findBy('id', params.task_id)

  setupController: (controller, model) ->
    currentPaperId = @controllerFor('paper.manage').get('model.id')
    taskController = @controllerFor('task')
    taskController.set('model', model)
    if currentPaperId == model.get('phase.paper.id')
      @set('shouldRenderManager', true)
      taskController.set('onClose', 'showManager')

    @set('taskName', model.get('type').replace(/Task$/,''))

  renderTemplate: ->
    @render(@get('taskName'),
      into: 'application'
      outlet: 'overlay'
      controller: 'task')
    if @get('shouldRenderManager')
      @render('paper/manage',
        into: 'application')
    else
      @render('overlay_background',
        into: 'application')
