import Ember from 'ember';

export const defaultMessage = 'can\'t be blank';

export const validation = function(value, options) {
  return !Ember.isEmpty(value);
};
