import Ember from 'ember';

export function isPresent(key) {
  return Ember.computed(key, function() {
    return Ember.isPresent(this.get(key));
  });
}
