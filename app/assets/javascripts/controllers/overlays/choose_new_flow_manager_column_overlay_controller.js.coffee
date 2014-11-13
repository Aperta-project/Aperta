ETahi.ChooseNewFlowManagerColumnOverlayController = Em.Controller.extend
  flows: []
  overlayClass: 'flow-manager-column-overlay overlay--fullscreen'
  actions:
    createFlow: (title) ->
      flow = @store.createRecord 'userFlow',
        title: title
      flow.save()
      @send('closeOverlay')
