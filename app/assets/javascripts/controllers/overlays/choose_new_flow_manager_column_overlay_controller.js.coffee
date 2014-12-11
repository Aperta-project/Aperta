ETahi.ChooseNewFlowManagerColumnOverlayController = Em.Controller.extend
  overlayClass: 'flow-manager-column-overlay overlay--fullscreen'

  isLoading: false
  flows: []

  groupedFlows: (->
    result = []

    titleFromFlow = (flow) -> (flow.journal_name || 'Default Flows')

    @get('flows').forEach (flow) ->
      unless result.findBy('title', titleFromFlow(flow))
        result.pushObject Ember.Object.create
          title: titleFromFlow(flow)
          logo: flow.journal_logo
          flows: []

      result.findBy('title', titleFromFlow(flow)).get('flows').pushObject(flow)

    return result
  ).property('flows.[]')

  actions:
    createFlow: (flow) ->
      flow = @store.createRecord 'userFlow',
        title: flow.title,
        flowId: flow.id,
        journalName: flow.journal_name,
        journalLogo: flow.journal_logo,

      flow.save()
      @send('closeOverlay')
