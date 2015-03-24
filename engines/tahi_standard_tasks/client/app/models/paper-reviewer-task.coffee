`import DS from 'ember-data'`
`import Task from 'tahi/models/task'`

PaperReviewerTask = Task.extend
  reviewers: DS.hasMany('user')
  invitations: DS.hasMany('invitation')
  relationshipsToSerialize: ['reviewers', 'participants']

`export default PaperReviewerTask`
