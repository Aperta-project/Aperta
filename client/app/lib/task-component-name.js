import Ember from 'ember';

export default function(taskType) {
  if(taskType.toLowerCase() === 'task') { return 'ad-hoc-task'; }
  return Ember.String.dasherize(taskType);
}
