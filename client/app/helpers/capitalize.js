import Ember from 'ember';

export default Ember.Helper.helper(function(params) {
  return Ember.String.capitalize(params[0] || "");
});
