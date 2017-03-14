import Answerable from 'tahi/mixins/answerable';
import DS from 'ember-data';
import NestedQuestionOwner from 'tahi/models/nested-question-owner';

export default NestedQuestionOwner.extend(Answerable, {
  decision: DS.belongsTo('decision'),
  task: DS.belongsTo('task'),
  user: DS.belongsTo('user'),
  status: DS.attr('string'),
  statusDatetime: DS.attr('date'),
  revision: DS.attr('string'),
  createdAt: DS.attr('date'),
  submitted: DS.attr('boolean')
});
