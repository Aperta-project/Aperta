import Ember from 'ember';

export default Ember.Helper.helper(function(params) {
  if(params[0] === 'Task') { return 'ad-hoc-task'; }
  return Ember.String.dasherize(params[0]);
});
