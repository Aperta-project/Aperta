`import DS from 'ember-data'`
`import Task from 'tahi/models/task'`

ReviseTask = Task.extend
  qualifiedType: "TahiStandardTasks::ReviseTask"

  decisions: DS.hasMany("decision")

`export default ReviseTask`
