ETahi.TaskAdapter = DS.ActiveModelAdapter.extend
  pathForType: (type) ->
    'tasks'

ETahi.AuthorsTaskAdapter = ETahi.TaskAdapter.extend()
ETahi.TechCheckTaskAdapter= ETahi.TaskAdapter.extend()
ETahi.RegisterDecisionTaskAdapter= ETahi.TaskAdapter.extend()
