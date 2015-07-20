`import DS from 'ember-data'`
`import Task from 'tahi/models/task'`

a = DS.attr

RegisterDecisionTask = Task.extend
  decisionLetters: a('string')
  paperDecision: a('string')
  paperDecisionLetter: a('string')
  acceptLetterTemplate: (->
    JSON.parse(@get('decisionLetters')).accept
  ).property 'decisionLetters'
  rejectLetterTemplate: (->
    JSON.parse(@get('decisionLetters')).reject
  ).property 'decisionLetters'
  majorRevisionLetterTemplate: (->
    JSON.parse(@get('decisionLetters')).major_revision
  ).property 'decisionLetters'
  minorRevisionLetterTemplate: (->
    JSON.parse(@get('decisionLetters')).minor_revision
  ).property 'decisionLetters'

`export default RegisterDecisionTask`
