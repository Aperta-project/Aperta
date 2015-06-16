import Ember from 'ember';
import urlToHref from 'tahi/lib/url-to-href';

export default Ember.Handlebars.makeBoundHelper(function(text) {
  return new Ember.Handlebars.SafeString(urlToHref(text, true));
});
