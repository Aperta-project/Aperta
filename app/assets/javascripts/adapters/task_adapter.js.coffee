ETahi.TaskAdapter = DS.ActiveModelAdapter.extend
  pathForType: (type) ->
    'tasks'
ETahi.PaperReviewerTaskAdapter = ETahi.TaskAdapter.extend()
ETahi.PaperEditorTaskAdapter = ETahi.TaskAdapter.extend()
ETahi.PaperAdminTaskAdapter = ETahi.TaskAdapter.extend()
ETahi.AuthorsTaskAdapter = ETahi.TaskAdapter.extend()
ETahi.DeclarationTaskAdapter= ETahi.TaskAdapter.extend()
ETahi.FigureTaskAdapter= ETahi.TaskAdapter.extend()
ETahi.MessageTaskAdapter= ETahi.TaskAdapter.extend()
ETahi.TechCheckTaskAdapter= ETahi.TaskAdapter.extend()
ETahi.RegisterDecisionTaskAdapter= ETahi.TaskAdapter.extend()
ETahi.ReviewerReportTaskAdapter= ETahi.TaskAdapter.extend()
ETahi.UploadManuscriptTaskAdapter= ETahi.TaskAdapter.extend()
