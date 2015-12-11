import Ember from 'ember';

export default Ember.Helper.helper(function(params) {
  return Ember.String.dasherize(params[0].toLowerCase()) + '-task';
});
