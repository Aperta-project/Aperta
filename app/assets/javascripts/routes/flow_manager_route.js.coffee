ETahi.FlowManagerRoute = Ember.Route.extend
  model: ->
    @store.find("flow")

  actions:
    chooseNewFlowMangerColumn: ->
      @render('chooseNewFlowManagerColumnOverlay',
        into: 'application'
        outlet: 'overlay'
        controller: 'chooseNewFlowManagerColumnOverlay')

    removeFlow: (flow) ->
      flow.destroyRecord()

    viewCard: (paper, task) ->
      currentType = task.get('type')
      currentType = 'AdHocTask' if currentType == 'Task'
      baseObjectName = (currentType || 'AdHocTask').replace('Task', 'Overlay')
      controller = @controllerFor(baseObjectName)
      controller.set('model', task)
      controller.set('paper', paper)

      @render(baseObjectName,
        into: 'application'
        outlet: 'overlay'
        controller: controller)
