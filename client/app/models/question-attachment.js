import DS from 'ember-data';

export default DS.Model.extend({
  nestedQuestionAnswer: DS.belongsTo('nested-question-answer', { async: false }),

  filename: DS.attr('string'),
  src: DS.attr('string'),
  status: DS.attr('string'),
  title: DS.attr('string'),
  caption: DS.attr('string')
});
