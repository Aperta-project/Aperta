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
      redirectParams = ['flow_manager']
      @controllerFor('application').set('overlayRedirect', redirectParams)
      @controllerFor('application').set('overlayBackground', 'paper/manage')
      @transitionTo('paper.task', paper, task)
