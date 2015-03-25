`import DS from 'ember-data'`
`import Task from 'tahi/models/task'`

FinancialDisclosureTask = Task.extend
  funders: DS.hasMany('funder')

`export default FinancialDisclosureTask`
