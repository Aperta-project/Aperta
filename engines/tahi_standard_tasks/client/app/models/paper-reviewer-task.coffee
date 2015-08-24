`import DS from 'ember-data'`
`import Task from 'tahi/models/task'`

PaperReviewerTask = Task.extend
  reviewers: DS.hasMany 'user'
  relationshipsToSerialize: ['reviewers', 'participants']
  invitationTemplate: DS.attr()

`export default PaperReviewerTask`
