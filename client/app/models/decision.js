import DS from 'ember-data';

export default DS.Model.extend({
  invitations: DS.hasMany('invitation', { async: false }),
  paper: DS.belongsTo('paper', { async: false }),
  nestedQuestionAnswers: DS.hasMany('nested-question-answer', { async: false }),
  createdAt: DS.attr('date'),
  isLatest: DS.attr('boolean'),
  letter: DS.attr('string'),
  revisionNumber: DS.attr('number'),
  verdict: DS.attr('string'),
  authorResponse: DS.attr('string'),
});
