import Ember from 'ember';

export default function(value, options) {
  return !Ember.isEmpty(value);
}
