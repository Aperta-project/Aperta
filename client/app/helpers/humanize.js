import Ember from 'ember';
import humanize from 'tahi/lib/humanize';

export default Ember.Helper.helper(function(params, hash) {
  return humanize(params[0]);
});
