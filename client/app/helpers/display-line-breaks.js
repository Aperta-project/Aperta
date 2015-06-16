import Ember from 'ember';
import lineBreakToTag from 'tahi/lib/line-break-to-tag';

export default Ember.Handlebars.makeBoundHelper(function(text) {
  // `text` could be String or Object from Handlebars subexpression
  let string = Ember.typeOf(text) === 'string' ? text : text.string;
  return new Ember.Handlebars.SafeString(lineBreakToTag(string));
});
