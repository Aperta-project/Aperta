import DS from 'ember-data';
import NestedQuestionOwner from 'tahi/models/nested-question-owner';

export default NestedQuestionOwner.extend({
  decision: DS.belongsTo('decision'),
  task: DS.belongsTo('task'),
  user: DS.belongsTo('user'),
  status: DS.attr('string'),
  createdAt: DS.attr('date')
});
