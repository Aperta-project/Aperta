ETahi.PaperReviewerOverlayController = ETahi.TaskController.extend
  reveiwersChanged: (->
    # @get('model.paper').then (paper) =>
    #   paper.get('tasks').then (tasks) =>
    #     tasks.findBy('title', 'Reviewer Report').deleteRecord()
  ).observes('reviewers.@each').on('isDeleted') #this doesnt work
