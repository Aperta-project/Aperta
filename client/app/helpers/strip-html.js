import Ember from 'ember';
import stripHtml from 'tahi/lib/strip-html';

export default Ember.Helper.helper(function(params) {
  return stripHtml(params[0]);
});
