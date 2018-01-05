import Ember from 'ember';
import formatDate from 'tahi/lib/format-date';

export default Ember.Helper.helper(function(params, hash) {
  if (typeof params[1] === 'string') {
    // convert string param to hash
    hash = { format: params[1] };
  }

  return formatDate(params[0], hash);
});
