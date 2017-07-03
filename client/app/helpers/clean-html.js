import Ember from 'ember';
import cleanHtml from 'tahi/lib/clean-html';

export default Ember.Helper.helper(function(params) {
  return cleanHtml(params[0]);
});
