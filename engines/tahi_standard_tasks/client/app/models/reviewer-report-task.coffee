`import DS from 'ember-data'`
`import Task from 'tahi/models/task'`

ReviewerReportTask = Task.extend
  paperReview: DS.belongsTo('paperReview')

`export default ReviewerReportTask`
