import Ember from 'ember';

export function isPresent(key) {
  return Ember.computed(key, function() {
    return Ember.isPresent(this.get(key));
  });
}

/**
 * Note that ember has both `isBlank` and `isEmpty` functions.
 * `isBlank` is essentially `isEmpty || isAWhitespaceString`
 */
export function isBlank(key) {
  return Ember.computed(key, function() {
    return Ember.isBlank(this.get(key));
  });
}
