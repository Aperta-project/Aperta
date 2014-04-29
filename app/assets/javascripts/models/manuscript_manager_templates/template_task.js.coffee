ETahi.TemplateTask = Em.Object.extend
  type: 'Task'

  isMessage: ( ->
    @get('type') == "MessageTask"
  ).property('type')

  title: (->
    @get('type').replace(/([a-z])([A-Z])/g, '$1 $2')
  ).property('type')

  destroy: ->
    @get('phase').removeTask(this)
