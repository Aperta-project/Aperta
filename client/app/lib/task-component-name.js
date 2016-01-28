import Ember from 'ember';

export default function(taskType) {
  if(taskType === 'Task') { return 'ad-hoc-task'; }
  return Ember.String.dasherize(taskType);
}
