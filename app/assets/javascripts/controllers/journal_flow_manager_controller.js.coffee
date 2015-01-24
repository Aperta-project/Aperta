ETahi.JournalFlowManagerController = Ember.ObjectController.extend
  flowSort: ['position:asc']
  sortedFlows: Ember.computed.sort('model.flows', 'flowSort')

  newFlowPosition: ->
    @get('sortedFlows.lastObject.position') + 1

  actions:
    saveFlow: (flow) ->
      flow.save().then ->
        Ember.run.schedule('afterRender', Tahi.utils.resizeColumnHeaders)

    removeFlow: (flow) ->
      flow.get('role.flows').then (flows) -> # SSOT workaround
        flows.removeObject(flow)

      flow.destroyRecord()

    addFlow: ->
      flow = @store.createRecord 'flow',
        title: 'Up for grabs'
        role: @get('model')
        position: @newFlowPosition()
        query: {}
        taskRoles: []

      flow.save().then (flow) -> # SSOT workaround
        flow.get('role.flows').then (flows) ->
          flows.addObject(flow)
