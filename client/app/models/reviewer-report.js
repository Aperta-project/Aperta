import Answerable from 'tahi/mixins/answerable';
import DS from 'ember-data';
import NestedQuestionOwner from 'tahi/models/nested-question-owner';
import Ember from 'ember';

export default NestedQuestionOwner.extend(Answerable, {
  decision: DS.belongsTo('decision'),
  task: DS.belongsTo('task'),
  user: DS.belongsTo('user'),
  status: DS.attr('string'),
  statusDatetime: DS.attr('date'),
  revision: DS.attr('string'),
  createdAt: DS.attr('date'),
  submitted: DS.attr('boolean'),
  // this is my best attempt at a hasOne in ember . . .
  dueDatetimes: DS.hasMany('due_datetime', { async: false }),
  dueDatetime: Ember.computed.alias('dueDatetimes.firstObject'),

  originallyDueAt: DS.attr('date'),
  needsSubmission: Ember.computed('status', 'submitted', function() {
    var status = this.get('status');
    return !this.get('submitted') && status === 'pending';
  }),
  scheduledEvents: DS.hasMany('scheduled-event')
});
