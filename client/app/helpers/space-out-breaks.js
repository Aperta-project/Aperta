import Ember from 'ember';
import spaceOutBreaks from 'tahi/lib/space-out-breaks';

export default Ember.Helper.helper(function(params) {
  return spaceOutBreaks(params[0]);
});
