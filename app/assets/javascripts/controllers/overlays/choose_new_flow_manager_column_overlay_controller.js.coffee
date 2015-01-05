ETahi.ChooseNewFlowManagerColumnOverlayController = Em.Controller.extend
  overlayClass: 'flow-manager-column-overlay overlay--fullscreen'

  isLoading: false
  flows: []

  groupedFlows: (->
    result = []

    @get('flows').forEach (flow) ->
      flowJournalName = flow.journal_name || 'Default Flows'
      unless result.findBy('title', flowJournalName)
        result.pushObject Ember.Object.create
          title: flowJournalName
          logo: flow.journal_logo
          flows: []

      result.findBy('title', flowJournalName).get('flows').pushObject(flow)

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
