`import DS from 'ember-data'`
`import Task from 'tahi/models/task'`

a = DS.attr

RegisterDecisionTask = Task.extend
  decisionLetters: a('string')
  paperDecision: a('string')
  paperDecisionLetter: a('string')
  acceptedLetterTemplate: (->
    JSON.parse(@get('decisionLetters')).Accepted
  ).property 'decisionLetters'
  rejectedLetterTemplate: (->
    JSON.parse(@get('decisionLetters')).Rejected
  ).property 'decisionLetters'
  reviseLetterTemplate: (->
    JSON.parse(@get('decisionLetters')).Revise
  ).property 'decisionLetters'

`export default RegisterDecisionTask`
