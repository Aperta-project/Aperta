ETahi.ApplicationRoute = Ember.Route.extend
  actions:
    showTaskOverlay: (task) ->
      taskName = task.get('type').replace(/Task$/,'')
      @controllerFor('task').set('model', task)
      @render(taskName,
        into: 'application'
        outlet: 'overlay'
        controller: 'task')

    showGenericOverlay: (templateName) ->
      @render(templateName,
        into: 'application'
        outlet: 'overlay')

    cardCreationOverlay: () ->
      paper = @controllerFor('paperManage').get('model')
      @controllerFor('newTask').set('model', paper)

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
    @store.find('task', params.task_id)

  setupController: (controller, model) ->
    oldPaperId = @controllerFor('paper.manage').get('model.id')
    if oldPaperId == model.get('phase.paper.id')
      @set('shouldRenderManager', true)
    @controllerFor('task').set('model', model)
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
