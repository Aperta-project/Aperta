`import ApplicationAdapter from 'tahi/adapters/application'`

TaskAdapter = ApplicationAdapter.extend
  pathForType: (type) ->
    'tasks'

`export default TaskAdapter`
