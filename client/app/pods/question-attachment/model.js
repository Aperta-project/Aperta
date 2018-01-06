import DS from 'ember-data';
import Readyable from 'tahi/mixins/models/readyable';

export default DS.Model.extend(Readyable, {
  answer: DS.belongsTo('answer', { async: false }),
  nestedQuestionAnswer: DS.belongsTo('nested-question-answer', { async: false }),

  filename: DS.attr('string'),
  src: DS.attr('string'),
  status: DS.attr('string'),
  title: DS.attr('string'),
  caption: DS.attr('string')
});
