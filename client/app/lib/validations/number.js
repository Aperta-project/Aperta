import Ember from 'ember';

export default function(value, options) {
  if (options.allowBlank && Ember.isEmpty(value)) {
    return true;
  }

  return !window.isNaN(value);
}
