ETahi.IndexController = Ember.ObjectController.extend
  currentUser:(-> Tahi.currentUser).property()
  hasSubmissions: Ember.computed.notEmpty('model.submissions')
  hasAssignedTasks: Ember.computed.notEmpty('model.assignedTasks')

  allTasks: Ember.computed.alias 'store.allTasks'
  viewableAssignedTasks: ( ->
    currentUser = @get('currentUser')
    flatTasks = _.flatten(@get('allTasks').mapBy('content'))
    flatTasks.filter (task) ->
      task.get('assignee.id') == currentUser.id.toString() || task.get('isMessage')
  ).property('allTasks.@each.[]')

  tasksByPaper:(->
    assignedTasks = @get('viewableAssignedTasks')
    tasksByPaper = @get('assignedPapers').map (paper) ->
      tasks = assignedTasks.filterBy('paper.content', paper)
      { shortTitle: paper.get('shortTitle'), id: paper.get('id'), tasks: tasks }
  ).property('viewableAssignedTasks')
