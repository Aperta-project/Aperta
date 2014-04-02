ETahi.FlowPaperView = Ember.View.extend
  templateName: 'flow'
  tasksForPaper: (->
    task_ids = @get('paperMap')[@get('paper.id')] || []
    if task_ids.length
      store = @get('controller.store')
      tasks = task_ids.map (idAndType) ->
        id = idAndType[0]
        type = idAndType[1]
        store.find(type, id)
    else
      task_ids
  ).property()
