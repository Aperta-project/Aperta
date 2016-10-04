import Ember from 'ember';

export default function(taskType) {
  return Ember.String.dasherize(taskType);
}
