import Ember from 'ember';

export function capitalizeWords(params) {
  let string = params[0];
  return Ember.String.w(string)
          .map((word) => Ember.String.capitalize(word)).join(' ');
}

export default Ember.Helper.helper(capitalizeWords);
