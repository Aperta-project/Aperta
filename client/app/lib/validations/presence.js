import Ember from 'ember';

export const defaultMessage = 'This field is required';

export const validation = function(value, options) {
  value = (typeof value === 'string') ? value.trim() : value;
  return !Ember.isEmpty(value);
};
