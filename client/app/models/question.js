import DS from 'ember-data';

export default DS.Model.extend({
  questionAttachment: DS.belongsTo('question-attachment'),
  task: DS.belongsTo('task', { polymorphic: true, inverse: 'questions' }),
  decision: DS.belongsTo('decision'),

  additionalData: DS.attr(),
  answer: DS.attr('string'),
  createdAt: DS.attr('date'),
  ident: DS.attr('string'),
  question: DS.attr('string'),
  updatedAt: DS.attr('date'),
  url: DS.attr('string')
});
