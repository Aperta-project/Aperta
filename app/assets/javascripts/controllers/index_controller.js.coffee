ETahi.IndexController = Ember.ObjectController.extend
  currentUser:(-> Tahi.currentUser).property()
  hasSubmissions: Ember.computed.notEmpty('model.submissions')
  hasAssignedTasks: Ember.computed.notEmpty('model.assignedTasks')

  viewableAssignedTasks: ( ->
    currentUser = @get('currentUser')
    cardThumbnails = @store.all('cardThumbnail')
    cardThumbnails.filter (thumbnail) ->
      thumbnail.get('assigneeId') == currentUser.id || thumbnail.get('isMessage')
  ).property()

  tasksByPaper:(->
    assignedTasks = @get('viewableAssignedTasks')
    tasksByPaper = @get('submissions').map (litePaper) ->
      tasks = assignedTasks.filterBy('paper', litePaper)
      { shortTitle: litePaper.get('shortTitle'), id: litePaper.get('id'), tasks: tasks }
  ).property('viewableAssignedTasks')
