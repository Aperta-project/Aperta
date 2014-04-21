ETahi.TemplateTask = Em.Object.extend
  type: 'Task'

  isMessage: ( ->
    @get('type') == "MessageTask"
  ).property('type')

  title: Ember.computed.alias('type')

  destroy: ->
    @get('phase').removeTask(this)
