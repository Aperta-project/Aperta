import Ember from 'ember';

export default function(string, count) {
  if(count !== 1) {
    return Ember.String.pluralize(string);
  }

  return string;
}
