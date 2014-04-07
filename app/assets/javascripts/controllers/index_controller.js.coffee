ETahi.IndexController = Ember.ObjectController.extend
  currentUser:(-> Tahi.currentUser).property()
  hasSubmissions: Ember.computed.notEmpty('submissions')
  hasAssignedTasks: Ember.computed.notEmpty('assigned_tasks')

  tasksByPaper:(->
    @get('assigned_tasks').map (item) =>
      paper = @get('task_papers').findBy('id', item.id)
      id: item.id
      shortTitle: paper.short_title
      title: paper.title
      tasks: item.tasks
  ).property('assigned_tasks')

