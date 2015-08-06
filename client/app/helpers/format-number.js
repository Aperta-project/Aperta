import Ember from 'ember';
import formatNumber from 'tahi/lib/format-number';

export default Ember.Helper.helper(function(params, hash) {
  return formatNumber(hash.number);
});
