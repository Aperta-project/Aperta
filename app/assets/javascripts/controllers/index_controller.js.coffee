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
    tasksByPaper = @get('submissions').map (litePaper) ->
      tasks = assignedTasks.filterBy('litePaper', litePaper)
      { shortTitle: litePaper.get('shortTitle'), id: litePaper.get('id'), tasks: tasks }
  ).property('viewableAssignedTasks')
