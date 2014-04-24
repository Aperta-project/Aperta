ETahi.TemplatePhase = Ember.Object.extend Ember.Copyable,
  tasks: []

  noTasks: Ember.computed.empty('tasks.[]')

  addTask: (newTask) ->
    @get('tasks').pushObject(newTask)
    newTask.set('phase', this)

  removeTask: (task) ->
    taskArray = @get('tasks')
    taskArray.removeAt(taskArray.indexOf(task))

  copy: (_) ->
    tasks = @get('tasks')
    newPhase = ETahi.TemplatePhase.create
      name: @get('name')
    newPhase.set 'tasks', tasks.map (task) ->
      ETahi.TemplateTask.create(type: task.get('type'), phase: newPhase)
    newPhase

