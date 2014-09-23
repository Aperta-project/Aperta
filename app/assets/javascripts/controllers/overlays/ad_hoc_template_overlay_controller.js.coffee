ETahi.AdHocTemplateOverlayController = Ember.ObjectController.extend ETahi.BuildsTaskTemplate,
  blocks: Ember.computed.alias('template')
  phaseTemplate: null

  actions:
    closeAction: ->
      @send('addTaskAndClose')
