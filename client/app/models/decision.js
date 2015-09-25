import DS from 'ember-data';
import NestedQuestionOwner from 'tahi/models/nested-question-owner';

export default NestedQuestionOwner.extend({
  invitations: DS.hasMany('invitation', { async: false }),
  paper: DS.belongsTo('paper', { async: false }),
  questions: DS.hasMany('question', { async: false }),

  createdAt: DS.attr('date'),
  isLatest: DS.attr('boolean'),
  letter: DS.attr('string'),
  revisionNumber: DS.attr('number'),
  verdict: DS.attr('string'),
  authorResponse: DS.attr('string'),
});
