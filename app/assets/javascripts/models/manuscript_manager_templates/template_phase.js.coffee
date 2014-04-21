ETahi.TemplatePhase = Ember.Object.extend
  tasks: []

  noTasks: Ember.computed.empty('tasks')

  addTask: (newTask) ->
    @get('tasks').pushObject(newTask)

  removeTask: (task) ->
    taskArray = @get('tasks')
    taskArray.removeAt(taskArray.indexOf(task))
