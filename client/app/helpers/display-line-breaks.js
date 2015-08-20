import Ember from 'ember';
import lineBreakToTag from 'tahi/lib/line-break-to-tag';

export default Ember.Helper.helper(function(params) {
  let string;

  if(Ember.typeOf(params[0]) === 'string') {
    string = params[0];
  } else if(Ember.typeOf(params[0]) === 'object' && params[0].string) {
    // `text` could be Object from HTMLBars subexpression
    string = params[0].string;
  }

  return lineBreakToTag(string);
});
