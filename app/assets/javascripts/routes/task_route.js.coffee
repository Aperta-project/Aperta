ETahi.TaskRoute = Ember.Route.extend
  model: (params) ->
    @store.find('task', params.task_id)

  setupController: (controller, model) ->
    # FIXME: Rename AdHocTask to Task (here, in views, and in templates)
    currentType = model.get('type')
    currentType = 'AdHocTask' if currentType == 'Task'
    baseObjectName = (currentType || 'AdHocTask').replace('Task', 'Overlay')
    @set('baseObjectName', baseObjectName)

    taskController = @controllerFor(baseObjectName)
    taskController.set('model', model)
    @set('taskController', taskController)

  renderTemplate: ->
    @render @get('baseObjectName'),
      into: 'application'
      outlet: 'overlay'
      controller: @get('taskController')

    @render('overlay_background',
      into: 'application')
