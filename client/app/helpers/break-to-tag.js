import Ember from 'ember';

export function breakToTag(string) {
  return (string || '').replace(/\n/g, '<br>');
}

export default Ember.Helper.helper(function(params) {
  return Ember.String.htmlSafe(breakToTag(params[0]));
});
