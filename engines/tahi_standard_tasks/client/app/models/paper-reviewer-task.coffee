`import DS from 'ember-data'`
`import Task from 'tahi/models/task'`

PaperReviewerTask = Task.extend
  reviewers: DS.hasMany 'user'
  decisions: DS.hasMany 'decision'
  relationshipsToSerialize: ['reviewers', 'participants']

`export default PaperReviewerTask`
