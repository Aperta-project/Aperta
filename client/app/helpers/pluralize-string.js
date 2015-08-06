import Ember from 'ember';
import pluralizeString from 'tahi/lib/pluralize-string';

export default Ember.Helper.helper(function(params, hash) {
  return pluralizeString(hash.string, hash.count);
});
