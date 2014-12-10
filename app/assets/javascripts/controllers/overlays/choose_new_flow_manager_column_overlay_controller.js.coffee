ETahi.ChooseNewFlowManagerColumnOverlayController = Em.Controller.extend
  overlayClass: 'flow-manager-column-overlay overlay--fullscreen'

  isLoading: false
  flows: []

  groupedFlows: (->
    result = []

    titleFromFlow = (flow) -> (flow.journalName || 'Default Flows')

    @get('flows').forEach (flow) ->
      unless result.findBy('title', titleFromFlow(flow))
        result.pushObject Ember.Object.create
          title: titleFromFlow(flow)
          logo: flow.journalLogo
          flows: []

      result.findBy('title', titleFromFlow(flow)).get('flows').pushObject(flow)

    return result
  ).property('flows.[]')

  actions:
    createFlow: (flow) ->
      flow = @store.createRecord 'userFlow',
        title: flow.title,
        flowId: flow.flow_id,
        journalName: flow.journalName,
        journalLogo: flow.journalLogo,

      flow.save()
      @send('closeOverlay')
