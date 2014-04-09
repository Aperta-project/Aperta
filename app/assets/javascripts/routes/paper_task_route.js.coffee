ETahi.PaperTaskRoute = Ember.Route.extend
  model: (params) ->
    paperTasks = _.flatten @modelFor('paper').get('phases').mapProperty('tasks.content')
    task = paperTasks.findBy('id', params.task_id)
    task.reload()

  setupController: (controller, model) ->
    # FIXME: Rename AdHocTask to Task (here, in views, and in templates)
    currentType = model.get('type')
    currentType = 'AdHocTask' if currentType == 'Task'
    baseObjectName = (currentType || 'AdHocTask').replace('Task', 'Overlay')
    @set('baseObjectName', baseObjectName)

    taskController = @controllerFor(baseObjectName)
    taskController.set('model', model)
    taskController.set('paper', model.get('paper'))
    @set('taskController', taskController)

    if @controllerFor('application').get('overlayRedirect')
      taskController.set('onClose', 'redirect')


  renderTemplate: ->
    @render @get('baseObjectName'),
      into: 'application'
      outlet: 'overlay'
      controller: @get('taskController')
    @render(@controllerFor('application').get('overlayBackground'))


  deactivate: ->
    @send('closeOverlay')
    @controllerFor('application').setProperties(overlayRedirect: null, overlayBackground: null)
