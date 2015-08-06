import Ember from 'ember';
import urlToHref from 'tahi/lib/url-to-href';

export default Ember.Helper.helper(function(params, hash) {
  let string;

  if(Ember.typeOf(hash.text) === 'string') {
    string = hash.text;
  } else if(Ember.typeOf(hash.text) === 'object' && hash.text.string) {
    // `text` could be Object from HTMLBars subexpression
    string = hash.text.string;
  }

  return Ember.String.htmlSafe(urlToHref(string, true));
});
