import Ember from 'ember';
import lineBreakToTag from 'tahi/lib/line-break-to-tag';

export default Ember.Handlebars.makeBoundHelper(function(text) {
  return new Ember.Handlebars.SafeString(lineBreakToTag(text));
});
