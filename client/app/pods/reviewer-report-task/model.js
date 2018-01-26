import Ember from 'ember';
import DS from 'ember-data';
import Task from 'tahi/pods/task/model';

export default Task.extend({
  decisions: DS.hasMany('decision', { async: true }),
  isSubmitted: DS.attr('boolean'),
  reviewerReports: DS.hasMany('reviewerReport', { inverse: 'task', async: true }),
  previousDecisions: Ember.computed.alias('task.paper.previousDecisions'),

  decision: Ember.computed('decisions', function() {
    return this.get('decisions').findBy('draft', true);
  })
});
