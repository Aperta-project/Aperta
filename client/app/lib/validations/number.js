import Ember from 'ember';

export const defaultMessage = 'must be a number';

export const validation = function(value, options={}) {
  return Ember.isEmpty(value) ? !!options.allowBlank : !window.isNaN(value);
};
