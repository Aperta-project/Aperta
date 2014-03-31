ETahi.TaskRoute = Ember.Route.extend
  model: (params) ->
    @store.find('task', params.task_id)

  actions:
    saveModel: ->
      @modelFor('paperTask').save()

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

    currentPaperId = @controllerFor('paper.manage').get('model.id')
    if currentPaperId == model.get('phase.paper.id')
      @set('shouldRenderManager', true)
      taskController.set('onClose', 'showManager')


  renderTemplate: ->
    @render @get('baseObjectName'),
      into: 'application'
      outlet: 'overlay'
      controller: @get('taskController')

    if @get 'shouldRenderManager'
      @render('paper/manage',
        into: 'application')
    else
      @render('overlay_background',
        into: 'application')
