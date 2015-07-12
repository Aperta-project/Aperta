import Ember from 'ember';
import lineBreakToTag from 'tahi/lib/line-break-to-tag';

export default Ember.Handlebars.makeBoundHelper(function(text='') {
  let string;

  if(Ember.typeOf(text) === 'string') {
    string = text;
  } else if(Ember.typeOf(text) === 'object' && text.string) {
    // `text` could be String or Object from Handlebars subexpression
    string = text.string;
  }

  return Ember.String.htmlSafe(lineBreakToTag(string));
});
