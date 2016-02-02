import Ember from 'ember';

export const defaultMessage = 'must be a number';

export const validation = function(value, options) {
  if (options.allowBlank && Ember.isEmpty(value)) {
    return true;
  }

  return !window.isNaN(value);
};
