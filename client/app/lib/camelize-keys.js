import Ember from 'ember';

export default function(object) {
  let camelized = {};

  Object.keys(object).forEach(function(key) {
    camelized[Ember.String.camelize(key)] = object[key];
  });

  return camelized;
}
