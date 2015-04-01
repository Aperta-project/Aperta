`import Ember from 'ember'`
`import BuildsTaskTemplate from 'tahi/mixins/controllers/builds-task-template'`

AdHocTemplateOverlayController = Ember.Controller.extend BuildsTaskTemplate,
  isNewTask: false
  blocks: Ember.computed.alias('template')
  phaseTemplate: null

  actions:
    closeAction: ->
      @send('addTaskAndClose')

`export default AdHocTemplateOverlayController`
