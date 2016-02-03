import Ember from 'ember';

export const defaultMessage = 'must be a number';

export const validation = function(value, options) {
  if (options && options.allowBlank && Ember.isEmpty(value)) {
    return true;
  }

  if(value === null) { return false; }

  return !window.isNaN(value);
};
