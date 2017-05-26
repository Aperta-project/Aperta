import Ember from 'ember';

export default Ember.Helper.helper(function(params) {
  let string = params[0];
  return string
          .split(' ')
          .map((word) => Ember.String.capitalize(word)).join(' ');
});