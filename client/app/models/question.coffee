`import DS from 'ember-data'`

Question = DS.Model.extend
  questionAttachment: DS.belongsTo('question-attachment')
  task: DS.belongsTo('task', polymorphic: true, inverse: 'questions')
  decision: DS.belongsTo('decision')

  ident: DS.attr('string')
  question: DS.attr('string')
  answer: DS.attr('string')
  additionalData: DS.attr()
  url: DS.attr('string')
  createdAt: DS.attr('date')
  updatedAt: DS.attr('date')

`export default Question`
