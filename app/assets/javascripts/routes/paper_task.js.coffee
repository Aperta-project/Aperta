ETahi.PaperTaskRoute = Ember.Route.extend
  model: (params) ->
    paperTasks = _.flatten @modelFor('paper').get('phases').mapProperty('tasks.content')
    paperTasks.findBy('id', params.task_id)

  setupController: (controller, model) ->
    currentPaperId = @controllerFor('paper.manage').get('model.id')
    taskControllerName = model.get('controllerName')
    taskController = @controllerFor(taskControllerName)
    @set('taskControllerName', taskControllerName)
    taskController.set('model', model)
    if currentPaperId == model.get('phase.paper.id')
      @set('shouldRenderManager', true)
      taskController.set('onClose', 'showManager')

    @set('taskName', model.get('type').replace(/Task$/,'') || 'AdHoc')

  renderTemplate: ->
    @render(@get('taskName'),
      into: 'application'
      outlet: 'overlay'
      controller: @get('taskControllerName'))
    if @get('shouldRenderManager')
      @render('paper/manage',
        into: 'application')
    else
      @render('overlay_background',
        into: 'application')
