import DS from 'ember-data';

export default DS.Model.extend({
  question: DS.belongsTo('question', { async: false }),
  nestedQuestionAnswer: DS.belongsTo('nested-question-answer', { async: false }),

  filename: DS.attr('string'),
  src: DS.attr('string'),
  status: DS.attr('string'),
  title: DS.attr('string')
});
