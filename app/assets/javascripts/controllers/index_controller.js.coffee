ETahi.IndexController = Ember.ObjectController.extend
  currentUser:(-> Tahi.currentUser).property()
  hasSubmissions: Ember.computed.notEmpty('model.submissions')
  hasAssignedTasks: Ember.computed.notEmpty('model.assignedTasks')

  viewableAssignedTasks: ( ->
    currentUser = @get('currentUser')
    cardThumbnails = @get('allCardThumbnails')
    cardThumbnails.filter (thumbnail) ->
      thumbnail.get('assigneeId') == currentUser.id.toString() || thumbnail.get('isMessage')
  ).property('allCardThumbnails.@each.[]', 'allCardThumbnails.@each.assigneeId',  'allCardThumbnails.@each.completed')

  tasksByPaper:(->
    assignedTasks = @get('viewableAssignedTasks')
    tasksByPaperId = _.groupBy(assignedTasks, (task) -> task.get('litePaper.id'))
    _(tasksByPaperId).map (tasks, litePaperId) =>
      litePaper = @store.getById('litePaper', litePaperId)
      { shortTitle: litePaper.get('shortTitle'), id: litePaper.get('id'), tasks: tasks }
  ).property('viewableAssignedTasks')
