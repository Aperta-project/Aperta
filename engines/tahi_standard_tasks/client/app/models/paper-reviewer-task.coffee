`import DS from 'ember-data'`
`import Task from 'tahi/models/task'`

a = DS.attr

PaperReviewerTask = Task.extend
  reviewers: DS.hasMany 'user'
  relationshipsToSerialize: ['reviewers', 'participants', 'letter']
  letter: a('string')
  invitationTemplate: (->
    JSON.parse(@get('letter'))
  ).property 'letter'

`export default PaperReviewerTask`
