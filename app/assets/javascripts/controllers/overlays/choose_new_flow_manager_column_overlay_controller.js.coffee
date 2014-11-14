ETahi.ChooseNewFlowManagerColumnOverlayController = Em.Controller.extend
  flows: ['Up for grabs', 'My Tasks', 'My Papers', 'Done']
  overlayClass: 'flow-manager-column-overlay overlay--fullscreen'
  actions:
    createFlow: (title) ->
      flow = @store.createRecord 'userFlow',
        title: title
      flow.save()
      @send('closeOverlay')
