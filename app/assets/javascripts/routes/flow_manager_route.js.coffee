ETahi.FlowManagerRoute = Ember.Route.extend
  model: ->
    @store.find("flow")

  actions:
    chooseNewFlowMangerColumn: ->
      @render('chooseNewFlowManagerColumnOverlay',
        into: 'application'
        outlet: 'overlay'
        controller: 'chooseNewFlowManagerColumnOverlay')
