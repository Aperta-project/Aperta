ETahi.AdHocTemplateOverlayController = Ember.ObjectController.extend ETahi.BuildsTaskTemplate,
  isNewTask: false
  blocks: Ember.computed.alias('template')
  phaseTemplate: null

  actions:
    closeAction: ->
      @send('addTaskAndClose')
