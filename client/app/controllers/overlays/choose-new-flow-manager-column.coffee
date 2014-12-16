`import Ember from 'ember'`

ChooseNewFlowManagerColumnOverlayController = Ember.Controller.extend
  flows: []
  overlayClass: 'flow-manager-column-overlay overlay--fullscreen'
  actions:
    createFlow: (flow) ->
      flow = @store.createRecord 'userFlow',
        title: flow.title
        flowId: flow.flow_id
      flow.save()
      @send('closeOverlay')

`export default ChooseNewFlowManagerColumnOverlayController`
