import Ember from 'ember';
import formatDate from 'tahi/lib/format-date';

export default Ember.Helper.helper(function(params, hash) {
  return formatDate(params[0], hash);
});
