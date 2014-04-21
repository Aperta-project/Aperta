ETahi.TemplatePhase = Ember.Object.extend
  tasks: []

  noTasks: Ember.computed.empty('tasks.[]')

  addTask: (newTask) ->
    @get('tasks').pushObject(newTask)
    newTask.set('phase', this)

  removeTask: (task) ->
    taskArray = @get('tasks')
    taskArray.removeAt(taskArray.indexOf(task))
