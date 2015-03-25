`import DS from 'ember-data'`
`import Task from 'tahi/models/task'`

PaperAdminTask = Task.extend
  admin: DS.belongsTo('user')

`export default PaperAdminTask`
