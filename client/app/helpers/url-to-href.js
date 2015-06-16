import Ember from 'ember';
import urlToHref from 'tahi/lib/url-to-href';

export default Ember.Handlebars.makeBoundHelper(function(text) {
  // `text` could be String or Object from Handlebars subexpression
  let string = Ember.typeOf(text) === 'string' ? text : text.string;
  return new Ember.Handlebars.SafeString(urlToHref(string, true));
});
