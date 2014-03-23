ETahi.PaperTaskRoute = Ember.Route.extend
  model: (params) ->
    paperTasks = _.flatten @modelFor('paper').get('phases').mapProperty('tasks.content')
    task = paperTasks.findBy('id', params.task_id)
    task.reload()

  actions:
    saveModel: ->
      @modelFor('paperTask').save()

  setupController: (controller, model) ->
    baseObjectName = (model.get('type') || 'AdHoc').replace('Task', 'Overlay')
    @set('baseObjectName', baseObjectName)

    taskController = @controllerFor(baseObjectName)
    taskController.set('model', model)
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
