import Answerable from 'tahi/mixins/answerable';
import DS from 'ember-data';
import NestedQuestionOwner from 'tahi/pods/nested-question-owner/model';
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
  dueDatetime: DS.belongsTo('due_datetime', { async: false }),

  originallyDueAt: DS.attr('date'),
  needsSubmission: Ember.computed('status', 'submitted', function() {
    var status = this.get('status');
    return !this.get('submitted') && status === 'pending';
  }),
  scheduledEvents: DS.hasMany('scheduled-event'),
  adminEdits: DS.hasMany('admin-edit'),
  activeAdminEdit: DS.attr('boolean'),
  inactiveAdminEdits: Ember.computed('adminEdits.@each.active', function() {
    if(this.get('adminEdits.length')) {
      return this.get('adminEdits').filterBy('active', false).sortBy('updatedAt').reverse();
    }
  })
});
