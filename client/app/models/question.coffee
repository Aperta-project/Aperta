`import DS from 'ember-data'`

a = DS.attr

Question = DS.Model.extend

  questionAttachment: DS.belongsTo('question-attachment')
  task: DS.belongsTo('task', polymorphic: true, inverse: 'questions')

  ident: a('string')
  question: a('string')
  answer: a('string')
  createdAt: a('date')
  updatedAt: a('date')
  additionalData: a()
  url: a('string')

`export default Question`
