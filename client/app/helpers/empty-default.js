import Ember from 'ember';

export default Ember.Helper.helper(function(params, hash) {
  return hash.text || hash.default;
});
