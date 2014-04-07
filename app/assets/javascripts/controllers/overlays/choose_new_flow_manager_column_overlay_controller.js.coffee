ETahi.ChooseNewFlowManagerColumnOverlayController = Em.Controller.extend
  flows: ['Up for grabs', 'My Tasks', 'My Papers', 'Done']
  overlayClass: 'flow-manager-column-overlay'
  actions:
    createFlow: (title) ->
      flow = @store.createRecord 'flow',
        title: title
      flow.save()
      @send('closeOverlay')
