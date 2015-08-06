import DS from 'ember-data';

export default DS.Model.extend({
  decision: DS.belongsTo('decision', { async: false }),
  questionAttachment: DS.belongsTo('question-attachment', { async: false }),
  task: DS.belongsTo('task', {
    polymorphic: true,
    inverse: 'questions',
    async: false
  }),

  additionalData: DS.attr(),
  answer: DS.attr('string'),
  createdAt: DS.attr('date'),
  ident: DS.attr('string'),
  question: DS.attr('string'),
  updatedAt: DS.attr('date'),
  url: DS.attr('string')
});
