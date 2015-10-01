`import Ember from 'ember'`
`import DS from 'ember-data'`
`import Task from 'tahi/models/task'`

ReviewerReportTask = Task.extend
  paperReview: DS.belongsTo('paperReview')
  decision: DS.belongsTo('decision')
  previousDecisions: DS.hasMany('previousDecision')
  isSubmitted: DS.attr('boolean')

  questionForIdentAndDecision: (ident, decision) ->
    @get('questions').find (question) ->
      question.get('ident') == ident && question.get('decision.id') == decision.get('id')

`export default ReviewerReportTask`
